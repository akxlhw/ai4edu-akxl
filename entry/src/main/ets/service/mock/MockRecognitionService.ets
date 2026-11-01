import { RecognizedItem } from '../RecognitionService';
import { MockHomeworkData } from './MockData';

/**
 * Mock 识别：对任意输入图返回同一组固定 6 题结构（设计第 6 节）。
 * 坐标按示例作业图版式设计，在示例图上标注与内容对齐；
 * 在其他图片上仅用于验证坐标链路（界面有「模拟数据」徽标说明）。
 */
export class MockRecognitionService {
  recognize(imageUri: string): Promise<RecognizedItem[]> {
    return Promise.resolve(MockHomeworkData.buildRecognizedItems());
  }
}
