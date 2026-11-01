import { RectF } from '../utils/RectF';

/**
 * 识别服务输出契约：切题 + OCR 结果。
 * 此时尚未判题，不含四态状态（判题由 GradingService 负责）。
 */
export class RecognizedItem {
  /** 题号（1 起） */
  index: number;
  /** 题干 */
  stem: string;
  /** 学生答案（识别文本） */
  studentAnswer: string;
  /** 题目区域，归一化坐标 0..1 */
  region: RectF;

  constructor(index: number, stem: string, studentAnswer: string, region: RectF) {
    this.index = index;
    this.stem = stem;
    this.studentAnswer = studentAnswer;
    this.region = region;
  }
}

/**
 * 识别服务契约（OCR 与整页切题，PRD A07/A08）。
 */
export interface RecognitionService {
  /** 对处理图切题并返回识别结果。 */
  recognize(imageUri: string): Promise<RecognizedItem[]>;
}
