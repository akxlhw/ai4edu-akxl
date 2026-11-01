import { HomeworkSession } from '../model/HomeworkSession';
import { Question } from '../model/Question';

/**
 * 会话单例（内存态）。V0.1 约定（设计 3.1/8 节）：
 * - 任务态经 NavPathStack 参数 + 本 store 传递；
 * - 会话仅内存态，退出即清；重复进入首页不残留上次会话。
 */
export class HomeworkSessionStore {
  private static instance: HomeworkSessionStore | null = null;
  private current: HomeworkSession | null = null;

  static getInstance(): HomeworkSessionStore {
    if (HomeworkSessionStore.instance === null) {
      HomeworkSessionStore.instance = new HomeworkSessionStore();
    }
    return HomeworkSessionStore.instance;
  }

  /** 开始新会话（覆盖旧会话，保证不残留）。 */
  startSession(processedImageUri: string, questions: Question[]): HomeworkSession {
    this.current = new HomeworkSession(processedImageUri, questions);
    return this.current;
  }

  /** 获取当前会话；无会话返回 null（页面需自行处理 null 兜底）。 */
  getSession(): HomeworkSession | null {
    return this.current;
  }

  /** 清空会话（页面返回/退出时调用）。 */
  clear(): void {
    this.current = null;
  }
}
