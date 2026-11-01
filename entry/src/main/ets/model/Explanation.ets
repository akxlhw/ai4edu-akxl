/**
 * 题目解析（设计第 5 节）。
 * 文案基调（PRD A15）：possibleCause 用"可能错因"而非武断评价；
 * hint 为渐进披露第一层，steps 为主动展开的第二层（UX-U12）。
 */
export class Explanation {
  /** 可能错因 */
  possibleCause: string;
  /** 思路提示（渐进披露第一层，默认可见） */
  hint: string;
  /** 分步解析（渐进披露第二层，主动展开） */
  steps: string[];
  /** 正确答案 */
  answer: string;
  /** 知识点 */
  knowledgePoint: string;

  constructor(possibleCause: string, hint: string, steps: string[],
    answer: string, knowledgePoint: string) {
    this.possibleCause = possibleCause;
    this.hint = hint;
    this.steps = steps;
    this.answer = answer;
    this.knowledgePoint = knowledgePoint;
  }
}
