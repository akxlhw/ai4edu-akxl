import { Question } from '../model/Question';
import { RecognizedItem } from './RecognitionService';

/**
 * 判题服务契约（PRD A10）。
 * 输出四态：CORRECT / INCORRECT / UNREADABLE / UNSUPPORTED；
 * 识别不清不得判错，暂不支持不得强行生成结论。
 */
export interface GradingService {
  /** 对识别结果逐题判题，返回带四态的 Question 列表。 */
  grade(items: RecognizedItem[]): Promise<Question[]>;
}
