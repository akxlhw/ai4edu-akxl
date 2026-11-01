/**
 * 矩形区域，单位由使用场景决定：
 * - 归一化空间：x/y/width/height 均为 0..1，相对最终处理图（旋转、裁切后）
 * - 显示空间：单位为 px，相对组件坐标系
 *
 * 见 docs/superpowers/specs/2026-10-31-v0.1-mock-loop-design.md 第 5/7 节。
 */
export class RectF {
  x: number;
  y: number;
  width: number;
  height: number;

  constructor(x: number, y: number, width: number, height: number) {
    this.x = x;
    this.y = y;
    this.width = width;
    this.height = height;
  }
}
