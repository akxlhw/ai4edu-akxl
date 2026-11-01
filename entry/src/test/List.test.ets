import localUnitTest from './LocalUnit.test';
import coordinateUtilTest from './CoordinateUtil.test';

export default function testsuite() {
  localUnitTest();
  coordinateUtilTest();
}
