import { RectF } from '../utils/RectF';

/**
 * 页面边界检测服务契约（预检页"自动检测建议框"，UX-U01）。
 * 未来接入真实检测时仅替换实现（service/mock 与 service/remote 同签名）。
 */
export interface PageDetector {
  /** 返回建议裁切框，归一化坐标 0..1。 */
  detect(imageUri: string): Promise<RectF>;
}
