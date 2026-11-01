import { camera } from '@kit.CameraKit';
import { image } from '@kit.ImageKit';
import fs from '@ohos.file.fs';
import { common } from '@kit.AbilityKit';

/**
 * 相机能力封装（后置摄像头，拍照存应用沙箱）。
 * 页面只负责 UI 与权限引导；会话生命周期由本类管理：
 * init(previewSurfaceId) → capture() → onPhotoTaken 回调 → release()。
 *
 * 设计 §3：拍照存应用沙箱；§13：Camera Kit 在平板上的取景方向属已知风险，
 * 以真机走查为准。
 */
export class CameraManager {
  private camManager: camera.CameraManager | null = null;
  private cameraInput: camera.CameraInput | null = null;
  private previewOutput: camera.PreviewOutput | null = null;
  private photoOutput: camera.PhotoOutput | null = null;
  private photoSession: camera.PhotoSession | null = null;
  private imageReceiver: image.ImageReceiver | null = null;
  private onPhotoTaken: ((uri: string) => void) | null = null;
  private appContext: common.UIAbilityContext | null = null;

  /** 注册拍照完成回调（返回沙箱文件 URI）。 */
  setPhotoTakenCallback(cb: (uri: string) => void): void {
    this.onPhotoTaken = cb;
  }

  /** 创建预览与拍照会话。surfaceId 来自 XComponent 的 onLoad。 */
  async init(previewSurfaceId: string, context: common.UIAbilityContext): Promise<void> {
    this.appContext = context;
    const mgr: camera.CameraManager = camera.getCameraManager(context);
    const devices: Array<camera.CameraDevice> = mgr.getSupportedCameras();
    let backDevice: camera.CameraDevice = devices[0];
    for (let i = 0; i < devices.length; i++) {
      if (devices[i].cameraPosition === camera.CameraPosition.CAMERA_POSITION_BACK) {
        backDevice = devices[i];
        break;
      }
    }

    const input: camera.CameraInput = mgr.createCameraInput(backDevice);
    await input.open();

    const capability: camera.CameraOutputCapability = mgr.getSupportedOutputCapability(backDevice);
    const previewProfile: camera.Profile = capability.previewProfiles[0];
    let photoProfile: camera.Profile = capability.photoProfiles[0];
    for (let i = 0; i < capability.photoProfiles.length; i++) {
      if (capability.photoProfiles[i].format === camera.CameraFormat.CAMERA_FORMAT_JPEG) {
        photoProfile = capability.photoProfiles[i];
        break;
      }
    }

    const previewOut: camera.PreviewOutput = mgr.createPreviewOutput(previewProfile, previewSurfaceId);
    const receiver: image.ImageReceiver = image.createImageReceiver(photoProfile.size.width,
      photoProfile.size.height, image.ImageFormat.JPEG, 8);
    const receiverSurfaceId: string = await receiver.getReceivingSurfaceId();
    const photoOut: camera.PhotoOutput = mgr.createPhotoOutput(photoProfile, receiverSurfaceId);
    receiver.on('imageArrival', () => {
      this.savePhotoToSandbox();
    });

    const session: camera.PhotoSession = mgr.createSession<camera.PhotoSession>(camera.SceneMode.NORMAL_PHOTO);
    session.beginConfig();
    session.addInput(input);
    session.addOutput(previewOut);
    session.addOutput(photoOut);
    await session.commitConfig();
    await session.start();

    this.camManager = mgr;
    this.cameraInput = input;
    this.previewOutput = previewOut;
    this.photoOutput = photoOut;
    this.photoSession = session;
    this.imageReceiver = receiver;
  }

  /** 触发拍照；结果经 onPhotoTaken 回调返回。 */
  async capture(): Promise<void> {
    if (this.photoOutput !== null) {
      const setting: camera.PhotoCaptureSetting = {
        quality: camera.QualityLevel.QUALITY_LEVEL_MEDIUM,
        rotation: camera.ImageRotation.ROTATION_0
      };
      await this.photoOutput.capture(setting);
    }
  }

  private async savePhotoToSandbox(): Promise<void> {
    const receiver: image.ImageReceiver | null = this.imageReceiver;
    const context: common.UIAbilityContext | null = this.appContext;
    if (receiver === null || context === null) {
      return;
    }
    const photo: image.Image = await receiver.readNextImage();
    const component: image.Component = await photo.getComponent(image.ComponentType.JPEG);
    const buffer: ArrayBuffer = component.byteBuffer;
    const filePath: string = `${context.filesDir}/homework_${Date.now()}.jpg`;
    const file = fs.openSync(filePath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
    fs.writeSync(file.fd, buffer);
    fs.closeSync(file);
    await photo.release();
    const cb: ((uri: string) => void) | null = this.onPhotoTaken;
    if (cb !== null) {
      cb(`file://${filePath}`);
    }
  }

  /** 释放相机资源（页面隐藏/销毁时调用，重复调用安全）。 */
  async release(): Promise<void> {
    const session: camera.PhotoSession | null = this.photoSession;
    const preview: camera.PreviewOutput | null = this.previewOutput;
    const photo: camera.PhotoOutput | null = this.photoOutput;
    const input: camera.CameraInput | null = this.cameraInput;
    try {
      if (session !== null) {
        await session.stop();
      }
    } catch (err) {
      // 停止失败不阻断后续释放
    }
    try {
      if (preview !== null) {
        await preview.release();
      }
    } catch (err) {
      // 忽略
    }
    try {
      if (photo !== null) {
        await photo.release();
      }
    } catch (err) {
      // 忽略
    }
    try {
      if (input !== null) {
        await input.close();
      }
    } catch (err) {
      // 忽略
    }
    try {
      if (session !== null) {
        await session.release();
      }
    } catch (err) {
      // 忽略
    }
    this.photoSession = null;
    this.previewOutput = null;
    this.photoOutput = null;
    this.cameraInput = null;
    this.imageReceiver = null;
    this.camManager = null;
  }
}
