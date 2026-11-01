import { RectF } from './RectF';

/**
 * ImageFit.Contain 布局结果：图片在显示区域内的实际绘制区。
 * offsetX/offsetY 为绘制区相对显示区域左上角的偏移（即留白补偿量）。
 */
export class ContainLayout {
  offsetX: number;
  offsetY: number;
  drawnWidth: number;
  drawnHeight: number;

  constructor(offsetX: number, offsetY: number, drawnWidth: number, drawnHeight: number) {
    this.offsetX = offsetX;
    this.offsetY = offsetY;
    this.drawnWidth = drawnWidth;
    this.drawnHeight = drawnHeight;
  }
}

/**
 * 归一化坐标与显示坐标的双向映射，防止标注框偏移的核心工具。
 *
 * 约定（设计第 7 节）：
 * - 题目区域坐标一律为相对最终处理图的归一化空间 0..1；
 * - 渲染时 = ContainLayout 偏移 + 归一化值 × 实际绘制尺寸；
 * - 本工具不做 clamp / 合法性校验，越界判断由调用方负责。
 */
export class CoordinateUtil {
  /**
   * 计算 ImageFit.Contain 下图片的实际绘制区。
   * scale = min(displayW / imageW, displayH / imageH)，绘制区在显示区域内居中。
   */
  static containLayout(imageWidth: number, imageHeight: number,
    displayWidth: number, displayHeight: number): ContainLayout {
    const scale: number = Math.min(displayWidth / imageWidth, displayHeight / imageHeight);
    const drawnWidth: number = imageWidth * scale;
    const drawnHeight: number = imageHeight * scale;
    const offsetX: number = (displayWidth - drawnWidth) / 2;
    const offsetY: number = (displayHeight - drawnHeight) / 2;
    return new ContainLayout(offsetX, offsetY, drawnWidth, drawnHeight);
  }

  /** 归一化区域 → 显示区域（px）。 */
  static normalizedToDisplay(region: RectF, layout: ContainLayout): RectF {
    return new RectF(
      layout.offsetX + region.x * layout.drawnWidth,
      layout.offsetY + region.y * layout.drawnHeight,
      region.width * layout.drawnWidth,
      region.height * layout.drawnHeight
    );
  }

  /** 显示区域（px）→ 归一化区域。normalizedToDisplay 的逆映射。 */
  static displayToNormalized(rect: RectF, layout: ContainLayout): RectF {
    return new RectF(
      (rect.x - layout.offsetX) / layout.drawnWidth,
      (rect.y - layout.offsetY) / layout.drawnHeight,
      rect.width / layout.drawnWidth,
      rect.height / layout.drawnHeight
    );
  }
}
