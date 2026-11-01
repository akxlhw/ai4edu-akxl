import { RectF } from '../utils/RectF';
import { QuestionStatus } from './QuestionStatus';
import { Explanation } from './Explanation';

/**
 * 一道题（设计第 5 节）。
 * region 为题目区域，归一化坐标 0..1，相对最终处理图（旋转、裁切后）。
 */
export class Question {
  /** 题号（1 起） */
  index: number;
  /** 题干 */
  stem: string;
  /** 学生答案（识别文本） */
  studentAnswer: string;
  /** 判题状态 */
  status: QuestionStatus;
  /** 题目区域（归一化） */
  region: RectF;
  /** 解析（判题后填充） */
  explanation: Explanation;

  constructor(index: number, stem: string, studentAnswer: string,
    status: QuestionStatus, region: RectF, explanation: Explanation) {
    this.index = index;
    this.stem = stem;
    this.studentAnswer = studentAnswer;
    this.status = status;
    this.region = region;
    this.explanation = explanation;
  }
}
