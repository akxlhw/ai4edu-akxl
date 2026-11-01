import { RectF } from '../utils/RectF';
import { ContainLayout, CoordinateUtil } from '../utils/CoordinateUtil';

/** 手柄角点：0=左上 1=右上 2=左下 3=右下。 */
enum Corner {
  TOP_LEFT,
  TOP_RIGHT,
  BOTTOM_LEFT,
  BOTTOM_RIGHT
}

/**
 * 裁切交互组件（设计 §3 预检页，UX-U01/U09）：
 * - 遮罩 + 裁切框 + 四角拖拽手柄 + 三等分网格（编辑态）
 * - 比例约束：0=自由；>0 时锁定 width/height 比，对角为锚点
 * - 裁切面积 < 建议框面积 60% 时顶部警示"可能裁掉题目"
 *
 * cropRegion 为归一化坐标（相对原图 0..1），与显示坐标的换算
 * 统一走 CoordinateUtil（Contain 留白补偿，防偏移核心）。
 */
@Component
export struct CropOverlay {
  /** 裁切框（归一化，双向）。 */
  @Link cropRegion: RectF
  /** 初始建议框（归一化），用于 60% 面积比较与外部重置。 */
  @Prop suggestedRegion: RectF
  /** 覆盖层尺寸（px）。 */
  @Prop displayWidth: number
  @Prop displayHeight: number
  /** 原图像素尺寸。 */
  @Prop imageWidth: number
  @Prop imageHeight: number
  /** 是否编辑态（显示手柄/网格）。 */
  @Prop editable: boolean
  /** 宽高比约束：0=自由。切换时立即把当前框调整为符合比例（中心为锚）。 */
  @Prop @Watch('onRatioChange') ratioLock: number
  @State warnVisible: boolean = false

  private layout: ContainLayout = new ContainLayout(0, 0, 1, 1);
  /** 拖拽起始时的显示坐标矩形。 */
  private dragStart: RectF = new RectF(0, 0, 0, 0);
  /** 比例切换的基准框（px）：拖拽结束时定格；切比例时从它取最大内接矩形，防反复切换缩水。 */
  private baseRect: RectF = new RectF(0, 0, 0, 0);

  aboutToAppear(): void {
    this.layout = CoordinateUtil.containLayout(this.imageWidth, this.imageHeight,
      this.displayWidth, this.displayHeight);
    this.baseRect = CoordinateUtil.normalizedToDisplay(this.suggestedRegion, this.layout);
  }

  /** 显示坐标矩形（px）。 */
  private displayRect(): RectF {
    return CoordinateUtil.normalizedToDisplay(this.cropRegion, this.layout);
  }

  private updateWarnState(): void {
    const cropArea: number = this.cropRegion.width * this.cropRegion.height;
    const suggestedArea: number =
      this.suggestedRegion.width * this.suggestedRegion.height;
    this.warnVisible = suggestedArea > 0 && cropArea / suggestedArea < 0.6;
  }

  /** 手柄拖拽：以对角为锚点重建矩形，应用比例约束与边界钳制。 */
  private onHandleDrag(corner: Corner, offsetX: number, offsetY: number): void {
    const start: RectF = this.dragStart;
    const minX: number = this.layout.offsetX;
    const minY: number = this.layout.offsetY;
    const maxX: number = this.layout.offsetX + this.layout.drawnWidth;
    const maxY: number = this.layout.offsetY + this.layout.drawnHeight;
    const minSize: number = 48;

    let left: number = start.x;
    let top: number = start.y;
    let right: number = start.x + start.width;
    let bottom: number = start.y + start.height;

    if (corner === Corner.TOP_LEFT) {
      left = start.x + offsetX;
      top = start.y + offsetY;
    } else if (corner === Corner.TOP_RIGHT) {
      right = start.x + start.width + offsetX;
      top = start.y + offsetY;
    } else if (corner === Corner.BOTTOM_LEFT) {
      left = start.x + offsetX;
      bottom = start.y + start.height + offsetY;
    } else {
      right = start.x + start.width + offsetX;
      bottom = start.y + start.height + offsetY;
    }

    // 比例约束：以对角为锚，宽度驱动高度
    if (this.ratioLock > 0) {
      const anchorX: number = (corner === Corner.TOP_LEFT || corner === Corner.BOTTOM_LEFT)
        ? right : left;
      const anchorY: number = (corner === Corner.TOP_LEFT || corner === Corner.TOP_RIGHT)
        ? bottom : top;
      let w: number = Math.abs(right - left);
      w = Math.max(w, minSize);
      const h: number = w / this.ratioLock;
      if (anchorX === left) {
        left = anchorX;
        right = anchorX + w;
      } else {
        right = anchorX;
        left = anchorX - w;
      }
      if (anchorY === top) {
        top = anchorY;
        bottom = anchorY + h;
      } else {
        bottom = anchorY;
        top = anchorY - h;
      }
    }

    // 边界与最小尺寸钳制
    left = Math.max(Math.min(left, maxX - minSize), minX);
    right = Math.max(Math.min(right, maxX), left + minSize);
    top = Math.max(Math.min(top, maxY - minSize), minY);
    bottom = Math.max(Math.min(bottom, maxY), top + minSize);

    const px: RectF = new RectF(left, top, right - left, bottom - top);
    const normalized: RectF = CoordinateUtil.displayToNormalized(px, this.layout);
    this.cropRegion.x = Math.max(0, Math.min(1, normalized.x));
    this.cropRegion.y = Math.max(0, Math.min(1, normalized.y));
    this.cropRegion.width = Math.min(1 - this.cropRegion.x, normalized.width);
    this.cropRegion.height = Math.min(1 - this.cropRegion.y, normalized.height);
    this.updateWarnState();
  }

  /** 比例切换：以基准框中心为锚，取基准框内符合新比例的最大内接矩形（防反复切换缩水）。 */
  private onRatioChange(): void {
    if (this.ratioLock <= 0) {
      return; // 切回自由：保持当前框
    }
    this.layout = CoordinateUtil.containLayout(this.imageWidth, this.imageHeight,
      this.displayWidth, this.displayHeight);
    const base: RectF = this.baseRect;
    const centerX: number = base.x + base.width / 2;
    const centerY: number = base.y + base.height / 2;
    let w: number = base.width;
    let h: number = w / this.ratioLock;
    if (h > base.height) {
      h = base.height;
      w = h * this.ratioLock;
    }
    if (w > this.layout.drawnWidth) {
      w = this.layout.drawnWidth;
      h = w / this.ratioLock;
    }
    if (h > this.layout.drawnHeight) {
      h = this.layout.drawnHeight;
      w = h * this.ratioLock;
    }
    const px: RectF = new RectF(centerX - w / 2, centerY - h / 2, w, h);
    const n: RectF = CoordinateUtil.displayToNormalized(px, this.layout);
    this.cropRegion.x = Math.max(0, Math.min(1, n.x));
    this.cropRegion.y = Math.max(0, Math.min(1, n.y));
    this.cropRegion.width = Math.min(1 - this.cropRegion.x, n.width);
    this.cropRegion.height = Math.min(1 - this.cropRegion.y, n.height);
    this.updateWarnState();
  }

  private handleX(corner: Corner): number {
    const r: RectF = this.displayRect();
    if (corner === Corner.TOP_LEFT || corner === Corner.BOTTOM_LEFT) {
      return r.x;
    }
    return r.x + r.width;
  }

  private handleY(corner: Corner): number {
    const r: RectF = this.displayRect();
    if (corner === Corner.TOP_LEFT || corner === Corner.TOP_RIGHT) {
      return r.y;
    }
    return r.y + r.height;
  }

  build() {
    Stack() {
      // 四周遮罩
      this.dimLayer()
      // 三等分网格（编辑态）
      if (this.editable) {
        this.gridLayer()
      }
      // 裁切框边线
      Column() {
      }
      .position({
        x: this.displayRect().x,
        y: this.displayRect().y
      })
      .width(this.displayRect().width)
      .height(this.displayRect().height)
      .border({ width: 2, color: Color.White })
      // 警示条
      if (this.warnVisible) {
        Text($r('app.string.crop_warn'))
          .fontSize($r('app.float.font_size_caption'))
          .fontColor('#8A5A00')
          .backgroundColor('#FFE9B0')
          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
          .borderRadius($r('app.float.radius_badge'))
          .position({ x: this.displayWidth / 2 - 110, y: 12 })
      }
      // 四角手柄（编辑态）
      if (this.editable) {
        this.handle(Corner.TOP_LEFT)
        this.handle(Corner.TOP_RIGHT)
        this.handle(Corner.BOTTOM_LEFT)
        this.handle(Corner.BOTTOM_RIGHT)
      }
    }
    .width('100%')
    .height('100%')
  }

  /** 四周半透明遮罩（裁切区外，上/下/左/右四块）。 */
  @Builder
  dimLayer() {
    // 上 / 下 / 左 / 右四块遮罩
    Column() {
    }
    .position({ x: 0, y: 0 })
    .width(this.displayWidth)
    .height(Math.max(0, this.displayRect().y))
    .backgroundColor('rgba(0,0,0,0.45)')
    Column() {
    }
    .position({ x: 0, y: this.displayRect().y + this.displayRect().height })
    .width(this.displayWidth)
    .height(Math.max(0, this.displayHeight - this.displayRect().y - this.displayRect().height))
    .backgroundColor('rgba(0,0,0,0.45)')
    Column() {
    }
    .position({ x: 0, y: this.displayRect().y })
    .width(Math.max(0, this.displayRect().x))
    .height(this.displayRect().height)
    .backgroundColor('rgba(0,0,0,0.45)')
    Column() {
    }
    .position({ x: this.displayRect().x + this.displayRect().width, y: this.displayRect().y })
    .width(Math.max(0, this.displayWidth - this.displayRect().x - this.displayRect().width))
    .height(this.displayRect().height)
    .backgroundColor('rgba(0,0,0,0.45)')
  }

  /** 三等分参考线。 */
  @Builder
  gridLayer() {
    Column() {
    }
    .position({
      x: this.displayRect().x + this.displayRect().width / 3,
      y: this.displayRect().y
    })
    .width(1)
    .height(this.displayRect().height)
    .backgroundColor('rgba(255,255,255,0.5)')
    Column() {
    }
    .position({
      x: this.displayRect().x + this.displayRect().width * 2 / 3,
      y: this.displayRect().y
    })
    .width(1)
    .height(this.displayRect().height)
    .backgroundColor('rgba(255,255,255,0.5)')
    Column() {
    }
    .position({
      x: this.displayRect().x,
      y: this.displayRect().y + this.displayRect().height / 3
    })
    .width(this.displayRect().width)
    .height(1)
    .backgroundColor('rgba(255,255,255,0.5)')
    Column() {
    }
    .position({
      x: this.displayRect().x,
      y: this.displayRect().y + this.displayRect().height * 2 / 3
    })
    .width(this.displayRect().width)
    .height(1)
    .backgroundColor('rgba(255,255,255,0.5)')
  }

  /** 角点手柄（可拖拽）。坐标实时读取状态——@Builder 参数是值快照，不能传坐标。 */
  @Builder
  handle(corner: Corner) {
    Column() {
    }
    .width(28)
    .height(28)
    .borderRadius(6)
    .backgroundColor(Color.White)
    .border({ width: 2, color: '#007DFF' })
    .position({ x: this.handleX(corner) - 14, y: this.handleY(corner) - 14 })
    .gesture(
      PanGesture({ fingers: 1 })
        .onActionStart(() => {
          const r: RectF = this.displayRect();
          this.dragStart = new RectF(r.x, r.y, r.width, r.height);
        })
        .onActionUpdate((event: GestureEvent) => {
          this.onHandleDrag(corner, event.offsetX, event.offsetY);
        })
        .onActionEnd(() => {
          this.baseRect = this.displayRect();
        })
    )
  }
}
