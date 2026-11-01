import { common } from '@kit.AbilityKit';
import { image } from '@kit.ImageKit';
import { CropPageParams, ImageSource } from '../model/CropPageParams';
import { ProcessingPageParams } from '../model/ProcessingPageParams';
import { RectF } from '../utils/RectF';
import { ImageLoader } from '../utils/ImageLoader';
import { CropOverlay } from '../components/CropOverlay';
import { MockPageDetector } from '../service/mock/MockPageDetector';
import { AnalyticsEvent, EventLogger } from '../service/analytics/EventLogger';

/**
 * 预检页（设计 §3，UX-U01/U09）：
 * - 自动检测建议框（mock 内缩 5%），默认直接「确认」进检查（主路径两步）
 * - 「调整」进入编辑：四角手柄/三等分网格/比例约束（自由/4:3/A4）
 * - 「重置」恢复建议框；「重拍/重新选择」按来源返回拍摄页
 * - 确认时按归一化区域裁出处理图（JPEG 存沙箱），供后续坐标链路使用
 */
@Component
export struct CropPage {
  private pathStack: NavPathStack = new NavPathStack();
  private params: CropPageParams | null = null;
  private detector: MockPageDetector = new MockPageDetector();
  @State pixelMap: image.PixelMap | undefined = undefined
  @State imageWidth: number = 1
  @State imageHeight: number = 1
  @State cropRegion: RectF = new RectF(0.05, 0.05, 0.90, 0.90)
  @State suggestedRegion: RectF = new RectF(0.05, 0.05, 0.90, 0.90)
  @State overlayWidth: number = 1
  @State overlayHeight: number = 1
  @State editing: boolean = false
  @State ratio: number = 0
  @State confirming: boolean = false

  build() {
    NavDestination() {
      Column() {
        // 图片 + 裁切覆盖层
        Stack() {
          if (this.pixelMap !== undefined) {
            Image(this.pixelMap)
              .objectFit(ImageFit.Contain)
              .width('100%')
              .height('100%')
          }
          if (this.pixelMap !== undefined) {
            CropOverlay({
              cropRegion: this.cropRegion,
              suggestedRegion: this.suggestedRegion,
              displayWidth: this.overlayWidth,
              displayHeight: this.overlayHeight,
              imageWidth: this.imageWidth,
              imageHeight: this.imageHeight,
              editable: this.editing,
              ratioLock: this.ratio
            })
          }
        }
        .layoutWeight(1)
        .width('100%')
        .onAreaChange((_oldValue: Area, newValue: Area) => {
          this.overlayWidth = Number(newValue.width);
          this.overlayHeight = Number(newValue.height);
        })

        // 底部操作区
        Column({ space: 12 }) {
          Text($r('app.string.crop_hint'))
            .fontSize($r('app.float.font_size_caption'))
            .fontColor($r('app.color.text_secondary'))

          if (this.editing) {
            Row({ space: 8 }) {
              this.ratioButton($r('app.string.ratio_free'), 0)
              this.ratioButton($r('app.string.ratio_4_3'), 4 / 3)
              this.ratioButton($r('app.string.ratio_a4'), 210 / 297)
            }
          }

          Row({ space: 12 }) {
            Button(this.params !== null && this.params.source === ImageSource.ALBUM
              ? $r('app.string.reselect') : $r('app.string.retake'))
              .secondaryButtonStyle()
              .onClick(() => {
                this.pathStack.pop();
              })
            Button($r('app.string.crop_reset'))
              .secondaryButtonStyle()
              .onClick(() => {
                EventLogger.log(AnalyticsEvent.CROP_RESET, new Map<string, string>());
                this.cropRegion = new RectF(this.suggestedRegion.x, this.suggestedRegion.y,
                  this.suggestedRegion.width, this.suggestedRegion.height);
              })
            Button($r('app.string.crop_adjust'))
              .secondaryButtonStyle()
              .onClick(() => {
                EventLogger.log(AnalyticsEvent.CROP_ADJUSTED, new Map<string, string>());
                this.editing = true;
              })
            Button($r('app.string.crop_confirm'))
              .primaryButtonStyle(this.confirming)
              .onClick(() => {
                this.confirm();
              })
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
        }
        .width('100%')
        .padding(16)
      }
      .width('100%')
      .height('100%')
    }
    .title($r('app.string.page_title_crop'))
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack;
      const param: object | undefined = context.pathInfo.param as CropPageParams;
      if (param !== undefined) {
        this.params = param as CropPageParams;
        this.prepare();
      }
    })
  }

  /** 加载图片并获取 mock 建议框。 */
  private async prepare(): Promise<void> {
    const params: CropPageParams | null = this.params;
    if (params === null) {
      return;
    }
    const pm: image.PixelMap = await ImageLoader.loadPixelMap(params.imageUri);
    this.pixelMap = pm;
    const info: image.ImageInfo = await pm.getImageInfo();
    this.imageWidth = info.size.width;
    this.imageHeight = info.size.height;
    const suggested: RectF = await this.detector.detect(params.imageUri);
    this.suggestedRegion = new RectF(suggested.x, suggested.y, suggested.width, suggested.height);
    this.cropRegion = new RectF(suggested.x, suggested.y, suggested.width, suggested.height);
  }

  /** 确认：裁出处理图并进入检查流程。 */
  private async confirm(): Promise<void> {
    if (this.confirming || this.params === null) {
      return;
    }
    this.confirming = true;
    const context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
    const outPath: string = `${context.filesDir}/processed_${Date.now()}.jpg`;
    const region: RectF = new RectF(this.cropRegion.x, this.cropRegion.y,
      this.cropRegion.width, this.cropRegion.height);
    try {
      const processedUri: string =
        await ImageLoader.cropToJpegFile(this.params.imageUri, region, outPath);
      EventLogger.log(AnalyticsEvent.CROP_CONFIRMED, new Map<string, string>());
      this.pathStack.pushPathByName('ProcessingPage', new ProcessingPageParams(processedUri));
    } catch (err) {
      // 裁切失败回到可调整状态，不中断流程
      this.confirming = false;
    }
  }

  @Builder
  ratioButton(label: Resource, value: number) {
    Button(label)
      .fontSize($r('app.float.font_size_caption'))
      .height(32)
      .padding({ left: 14, right: 14 })
      .backgroundColor(this.ratio === value ? '#007DFF' : $r('app.color.page_background'))
      .fontColor(this.ratio === value ? Color.White : $r('app.color.text_secondary'))
      .onClick(() => {
        this.ratio = value;
      })
  }
}

/** 次级按钮。 */
@Extend(Button)
function secondaryButtonStyle() {
  .backgroundColor($r('app.color.page_background'))
  .fontColor($r('app.color.text_primary'))
  .fontSize($r('app.float.font_size_caption'))
  .height(40)
  .layoutWeight(1)
}

/** 主按钮。 */
@Extend(Button)
function primaryButtonStyle(busy: boolean) {
  .backgroundColor(busy ? '#66AFFF' : $r('app.color.cta_primary'))
  .fontColor(Color.White)
  .fontSize($r('app.float.font_size_body'))
  .height(40)
  .layoutWeight(1)
  .enabled(!busy)
}

@Builder
export function cropPageBuilder(name: string) {
  CropPage()
}
