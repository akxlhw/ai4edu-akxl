import { abilityAccessCtrl, common, Want } from '@kit.AbilityKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { CropPageParams, ImageSource } from '../model/CropPageParams';
import { CameraManager } from '../service/camera/CameraManager';
import { AnalyticsEvent, EventLogger } from '../service/analytics/EventLogger';

/** 权限状态。 */
enum PermState {
  PENDING,
  GRANTED,
  DENIED
}

/**
 * 拍摄页（设计 §3）：
 * - Camera Kit 预览 + 拍照存应用沙箱
 * - 取景引导框 + 文案（UX-U10）
 * - 右上角「从相册选择」→ PhotoViewPicker（UX-U02）
 * - 相机权限被拒 → 引导视图：「去设置」+「改从相册选择」降级（UX-U08）
 * - 相册取消：静默停留本页，不产生会话数据（设计 §8）
 */
@Component
export struct CapturePage {
  private pathStack: NavPathStack = new NavPathStack();
  private cameraManager: CameraManager = new CameraManager();
  private xcc: XComponentController = new XComponentController();
  private abilityContext: common.UIAbilityContext | null = null;
  private previewSurfaceId: string | null = null;
  private cameraReady: boolean = false;
  @State permission: PermState = PermState.PENDING;

  aboutToAppear(): void {
    this.abilityContext = getContext(this) as common.UIAbilityContext;
    this.cameraManager.setPhotoTakenCallback((uri: string): void => this.onPhotoTaken(uri));
    this.requestCameraPermission();
  }

  aboutToDisappear(): void {
    this.cameraManager.release();
  }

  private async requestCameraPermission(): Promise<void> {
    const context: common.UIAbilityContext | null = this.abilityContext;
    if (context === null) {
      this.permission = PermState.DENIED;
      return;
    }
    try {
      const atManager = abilityAccessCtrl.createAtManager();
      const result = await atManager.requestPermissionsFromUser(context, ['ohos.permission.CAMERA']);
      this.permission = result.authResults[0] === 0 ? PermState.GRANTED : PermState.DENIED;
    } catch (err) {
      this.permission = PermState.DENIED;
    }
  }

  private async initCamera(surfaceId: string): Promise<void> {
    if (this.cameraReady || this.abilityContext === null) {
      return;
    }
    try {
      await this.cameraManager.init(surfaceId, this.abilityContext);
      this.cameraReady = true;
    } catch (err) {
      // 相机初始化失败（占用/硬件异常）：走相册降级视图
      this.permission = PermState.DENIED;
    }
  }

  private onPhotoTaken(uri: string): void {
    EventLogger.log(AnalyticsEvent.CAPTURE_COMPLETE, new Map<string, string>());
    this.goCrop(uri, ImageSource.CAMERA);
  }

  private goCrop(imageUri: string, source: ImageSource): void {
    this.pathStack.pushPathByName('CropPage', new CropPageParams(imageUri, source));
  }

  /** 系统相册选择器；取消时静默停留（设计 §8）。 */
  private async openAlbum(): Promise<void> {
    const picker: photoAccessHelper.PhotoViewPicker = new photoAccessHelper.PhotoViewPicker();
    const options: photoAccessHelper.PhotoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
    options.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
    options.maxSelectNumber = 1;
    const result: photoAccessHelper.PhotoSelectResult = await picker.select(options);
    if (result.photoUris.length > 0) {
      EventLogger.log(AnalyticsEvent.ALBUM_PICKED, new Map<string, string>());
      this.goCrop(result.photoUris[0], ImageSource.ALBUM);
    }
  }

  /** 跳系统设置的本应用详情页（UX-U08「去设置」）。 */
  private openAppSettings(): void {
    const context: common.UIAbilityContext | null = this.abilityContext;
    if (context === null) {
      return;
    }
    const want: Want = {
      bundleName: 'com.huawei.hmos.settings',
      abilityName: 'com.huawei.hmos.settings.MainAbility',
      uri: 'application_info'
    };
    context.startAbility(want);
  }

  build() {
    NavDestination() {
      if (this.permission === PermState.GRANTED) {
        this.cameraView()
      }
      if (this.permission === PermState.DENIED) {
        this.deniedView()
      }
      if (this.permission === PermState.PENDING) {
        Column({ space: 12 }) {
          LoadingProgress().width(36).height(36)
        }
        .justifyContent(FlexAlign.Center)
        .height('100%')
        .width('100%')
      }
    }
    .title($r('app.string.page_title_capture'))
    .backgroundColor(Color.Black)
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack;
    })
    .onShown(() => {
      // 从后页返回时恢复预览（onHidden 中已释放）
      const sid: string | null = this.previewSurfaceId;
      if (sid !== null && this.permission === PermState.GRANTED) {
        this.initCamera(sid);
      }
    })
    .onHidden(() => {
      // 页面被覆盖即停相机，避免后台占用（隐私红线）
      this.cameraManager.release();
      this.cameraReady = false;
    })
  }

  /** 相机取景视图。 */
  @Builder
  cameraView() {
    Stack({ alignContent: Alignment.Top }) {
      XComponent({ id: 'capture_preview', type: XComponentType.SURFACE, libraryname: '',
        controller: this.xcc })
        .onLoad(() => {
          const sid: string = this.xcc.getXComponentSurfaceId();
          this.previewSurfaceId = sid;
          if (this.permission === PermState.GRANTED) {
            this.initCamera(sid);
          }
        })
        .onDestroy(() => {
          this.previewSurfaceId = null;
          this.cameraManager.release();
          this.cameraReady = false;
        })
        .width('100%')
        .height('100%')

      // 取景引导：顶部文案 + 参考框（UX-U10）
      Column({ space: 12 }) {
        Row() {
          Blank()
          Button($r('app.string.album_entry'))
            .backgroundColor('rgba(0,0,0,0.35)')
            .fontColor(Color.White)
            .fontSize($r('app.float.font_size_caption'))
            .height(36)
            .padding({ left: 16, right: 16 })
            .onClick(() => {
              this.openAlbum();
            })
        }
        .width('100%')

        Text($r('app.string.capture_guide'))
          .fontSize($r('app.float.font_size_caption'))
          .fontColor(Color.White)
          .textAlign(TextAlign.Center)
          .width('100%')

        // 参考框（居中）
        Column() {
        }
        .border({ width: 2, color: 'rgba(255,255,255,0.7)', radius: 16 })
        .width('86%')
        .height('62%')
        .margin({ top: 24 })
      }
      .width('100%')

      // 底部快门
      Column() {
        Row({ space: 48 }) {
          Button($r('app.string.album_entry'))
            .backgroundColor('rgba(0,0,0,0.35)')
            .fontColor(Color.White)
            .fontSize($r('app.float.font_size_caption'))
            .height(36)
            .padding({ left: 16, right: 16 })
            .onClick(() => {
              this.openAlbum();
            })
          Button() {
            Circle({ width: 68, height: 68 }).fill(Color.White)
          }
          .backgroundColor(Color.Transparent)
          .onClick(() => {
            this.cameraManager.capture();
          })
          // 占位与相册按钮对称，保持快门居中
          Column().width(88).height(36)
        }
        .justifyContent(FlexAlign.Center)
        .width('100%')
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.End)
      .padding({ bottom: 32 })
    }
    .width('100%')
    .height('100%')
  }

  /** 权限被拒引导视图（UX-U08）。 */
  @Builder
  deniedView() {
    Column({ space: 16 }) {
      Column() {
        Text('相机')
          .fontSize($r('app.float.font_size_title'))
          .fontColor(Color.White)
      }
      .width(80)
      .height(80)
      .borderRadius(40)
      .backgroundColor('rgba(255,255,255,0.15)')
      .justifyContent(FlexAlign.Center)

      Text($r('app.string.camera_denied_title'))
        .fontSize($r('app.float.font_size_body'))
        .fontColor(Color.White)
      Text($r('app.string.camera_denied_desc'))
        .fontSize($r('app.float.font_size_caption'))
        .fontColor('rgba(255,255,255,0.7)')
        .textAlign(TextAlign.Center)
        .padding({ left: 32, right: 32 })

      Row({ space: 12 }) {
        Button($r('app.string.go_settings'))
          .backgroundColor('#007DFF')
          .fontColor(Color.White)
          .fontSize($r('app.float.font_size_body'))
          .height(44)
          .padding({ left: 24, right: 24 })
          .onClick(() => {
            this.openAppSettings();
          })
        Button($r('app.string.use_album'))
          .backgroundColor('rgba(255,255,255,0.2)')
          .fontColor(Color.White)
          .fontSize($r('app.float.font_size_body'))
          .height(44)
          .padding({ left: 24, right: 24 })
          .onClick(() => {
            this.openAlbum();
          })
      }
      .margin({ top: 16 })
    }
    .justifyContent(FlexAlign.Center)
    .width('100%')
    .height('100%')
  }
}

@Builder
export function capturePageBuilder(name: string) {
  CapturePage()
}
