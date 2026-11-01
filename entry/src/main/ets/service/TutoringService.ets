import { Question } from '../model/Question';
import { Explanation } from '../model/Explanation';

/**
 * 辅导服务契约（错因 + 解析，PRD A14/A15）。
 * 渐进披露数据结构由 Explanation 承载：可能错因 + 思路提示默认可见，分步解析主动展开。
 */
export interface TutoringService {
  /** 为错题生成解析内容。 */
  explain(question: Question): Promise<Explanation>;
}
