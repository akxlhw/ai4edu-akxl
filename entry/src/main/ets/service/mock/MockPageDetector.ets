import { RectF } from '../../utils/RectF';
import { PageDetector } from '../PageDetector';

/**
 * Mock 页面检测：默认全图内缩约 5%，模拟自动检测结果（设计第 3/6 节）。
 */
export class MockPageDetector implements PageDetector {
  detect(imageUri: string): Promise<RectF> {
    return Promise.resolve(new RectF(0.05, 0.05, 0.90, 0.90));
  }
}
