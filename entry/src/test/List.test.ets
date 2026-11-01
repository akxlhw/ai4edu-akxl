import localUnitTest from './LocalUnit.test';
import coordinateUtilTest from './CoordinateUtil.test';
import homeworkSessionTest from './HomeworkSession.test';
import mockServiceTest from './MockService.test';

export default function testsuite() {
  localUnitTest();
  coordinateUtilTest();
  homeworkSessionTest();
  mockServiceTest();
}
