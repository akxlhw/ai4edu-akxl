import { describe, it, expect } from '@ohos/hypium';
import { RectF } from '../main/ets/utils/RectF';
import { ContainLayout, CoordinateUtil } from '../main/ets/utils/CoordinateUtil';

/** 浮点近似断言（避免二进制浮点误差导致误报）。 */
function expectClose(actual: number, expected: number): void {
  expect(Math.abs(actual - expected) < 1e-9).assertTrue();
}

function expectRectClose(actual: RectF, x: number, y: number, width: number, height: number): void {
  expectClose(actual.x, x);
  expectClose(actual.y, y);
  expectClose(actual.width, width);
  expectClose(actual.height, height);
}

export default function coordinateUtilTest() {
  describe('CoordinateUtilTest', () => {
    // ---- containLayout：ImageFit.Contain 绘制区计算 ----

    it('containLayout_identity', 0, () => {
      const layout = CoordinateUtil.containLayout(100, 100, 100, 100);
      expectClose(layout.offsetX, 0);
      expectClose(layout.offsetY, 0);
      expectClose(layout.drawnWidth, 100);
      expectClose(layout.drawnHeight, 100);
    });

    it('containLayout_uniformScale2x', 0, () => {
      // 宽高比一致，整比放大 2 倍，无留白
      const layout = CoordinateUtil.containLayout(100, 50, 200, 100);
      expectClose(layout.offsetX, 0);
      expectClose(layout.offsetY, 0);
      expectClose(layout.drawnWidth, 200);
      expectClose(layout.drawnHeight, 100);
    });

    it('containLayout_horizontalLetterbox', 0, () => {
      // 竖图 100x200 放进 200x200：scale=1，左右各留白 50
      const layout = CoordinateUtil.containLayout(100, 200, 200, 200);
      expectClose(layout.offsetX, 50);
      expectClose(layout.offsetY, 0);
      expectClose(layout.drawnWidth, 100);
      expectClose(layout.drawnHeight, 200);
    });

    it('containLayout_verticalLetterbox', 0, () => {
      // 横图 200x100 放进 100x100：scale=0.5，上下各留白 25
      const layout = CoordinateUtil.containLayout(200, 100, 100, 100);
      expectClose(layout.offsetX, 0);
      expectClose(layout.offsetY, 25);
      expectClose(layout.drawnWidth, 100);
      expectClose(layout.drawnHeight, 50);
    });

    // ---- normalizedToDisplay：归一化 → 显示 ----

    it('normalizedToDisplay_identity', 0, () => {
      const layout = new ContainLayout(0, 0, 100, 100);
      const display = CoordinateUtil.normalizedToDisplay(new RectF(0.5, 0.5, 0.25, 0.25), layout);
      expectRectClose(display, 50, 50, 25, 25);
    });

    it('normalizedToDisplay_uniformScale', 0, () => {
      const layout = new ContainLayout(0, 0, 200, 100);
      const display = CoordinateUtil.normalizedToDisplay(new RectF(0.5, 0.5, 0.2, 0.1), layout);
      expectRectClose(display, 100, 50, 40, 10);
    });

    it('normalizedToDisplay_withHorizontalLetterbox', 0, () => {
      const layout = new ContainLayout(50, 0, 100, 200);
      const display = CoordinateUtil.normalizedToDisplay(new RectF(0.5, 0.5, 0.2, 0.1), layout);
      expectRectClose(display, 100, 100, 20, 20);
    });

    it('normalizedToDisplay_withVerticalLetterbox', 0, () => {
      const layout = new ContainLayout(0, 25, 100, 50);
      const display = CoordinateUtil.normalizedToDisplay(new RectF(0.5, 0.5, 0.2, 0.1), layout);
      expectRectClose(display, 50, 50, 20, 5);
    });

    it('normalizedToDisplay_fullImage', 0, () => {
      // 全图区域 (0,0,1,1) 应精确铺满绘制区
      const layout = new ContainLayout(50, 0, 100, 200);
      const display = CoordinateUtil.normalizedToDisplay(new RectF(0, 0, 1, 1), layout);
      expectRectClose(display, 50, 0, 100, 200);
    });

    it('normalizedToDisplay_bottomRightCorner', 0, () => {
      // 边界值：归一化 (1,1) 对应绘制区右下角
      const layout = new ContainLayout(50, 25, 100, 50);
      const display = CoordinateUtil.normalizedToDisplay(new RectF(1, 1, 0, 0), layout);
      expectRectClose(display, 150, 75, 0, 0);
    });

    // ---- displayToNormalized：显示 → 归一化（逆映射） ----

    it('displayToNormalized_roundTrip', 0, () => {
      const layout = new ContainLayout(50, 25, 100, 50);
      const region = new RectF(0.3, 0.6, 0.2, 0.1);
      const roundTrip = CoordinateUtil.displayToNormalized(
        CoordinateUtil.normalizedToDisplay(region, layout), layout);
      expectRectClose(roundTrip, 0.3, 0.6, 0.2, 0.1);
    });

    it('displayToNormalized_identityLayout', 0, () => {
      const layout = new ContainLayout(0, 0, 200, 100);
      const region = CoordinateUtil.displayToNormalized(new RectF(100, 50, 40, 10), layout);
      expectRectClose(region, 0.5, 0.5, 0.2, 0.1);
    });
  });
}
