# YWAutoPackage - iOS项目自动打包脚本

>⚠️注意：
>
> 项目第一次必须手动打包成功才能正常使用该脚本，Xcode 手动打包后才会把打包所需文件备齐

##### Github地址：[https://github.com/AAWayne/YWAutoPackage](https://github.com/AAWayne/YWAutoPackage)

### 使用方法：[点击下载脚本相关文件](https://codeload.github.com/AAWayne/YWAutoPackage/zip/master)

1、将`YWAutoPackage文件夹`直接拖到`桌面`后

2、配置打开编辑`YWAutoPackage.sh`中的配置相关参数

3、再将`YWAutoPackage.sh`脚本文件拖入`终端`回车即可执行自动打包脚本

4、执行脚本后按需求输入选择打包版本

	Dev 开发版、Hoc 测试版、App Store 生产版、Enterprise 企业版

5、如果执行脚本时出现如下错误是因为文件权限不足，只需对其授权777即可

```
-bash: /Users/candy/Desktop/YWAutoPackage/YWAutoPackage.sh: Permission denied
```
执行如下授权命令即可（这里的参考了上面的路径地址）

```
chmod -R 777 /Users/candy/Desktop/YWAutoPackage/YWAutoPackage.sh
```

6、如果需要上传 App Store，则安装 Transporter 上传工具，并且配置开发者账号和专用密码


### 打包脚本核心内容展示

```
# 先组装路径 archive_path、ipa_path ，用于导出 ipa 和 上传
archive_path="${temp_path}/${ipa_dir}/${pro_name}.xcarchive"
ipa_path="${temp_path}/${ipa_dir}/${pro_name}.ipa"

# Clean操作
xcodebuild clean -${pro_clean} ${pro_full_name} -scheme ${pro_name} -configuration ${pro_environ}
judgementLastIsSuccsess $? "Clean"

# Archive操作
xcodebuild archive -${pro_clean} ${pro_full_name} -scheme ${pro_name} -archivePath ${archive_path}
judgementLastIsSuccsess $? "Archive"

# 导出IPA文件操作
xcodebuild -exportArchive -archivePath ${archive_path} -exportOptionsPlist ${plist_path} -exportPath ${temp_path}/${ipa_dir}
judgementLastIsSuccsess $? "导出IPA文件"

# 删除 xcarchive 包
rm -r ${archive_path}


# ============ 上传到App Store ============  
# 获取 Transporter 上传工具【推荐】
toolPath="/Applications/Transporter.app/Contents/itms/bin/iTMSTransporter"
${toolPath} -m upload -assetFile ${ipa_path} -u ${apple_id} -p ${apple_pwd} -v informational
# ============ 上传到App Store ============ 
 
```
### 如果不上传蒲公英或不上传App Store的话 注释下面两句话即可（如果没填写相关账号则不会执行上传操作）

```
# 上传蒲公英分发平台
uploadPGY

# 上传 App Store
uploadAppStore
```

<div align="center">
<img src = "https://upload-images.jianshu.io/upload_images/2822163-1b59ac9d4417b718.png" align = center />
</div>

<div align="center">
<img src = "http://upload-images.jianshu.io/upload_images/2822163-23eb59c7072548bb.png" width = "300" height = "100" alt="图片名称" align = center />
</div>
