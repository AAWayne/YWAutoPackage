# AutoPackage - iOS项目自动打包脚本
### 使用方法：
1、将`AutoPackage.sh` 脚本和`autoplist文件夹`拖入`项目根目录`后

2、配置打开编辑`AutoPackage.sh`中的配置参数（若只打包，则只需配置`pro_full_name`即可）

3、再将`AutoPackage.sh`脚本文件拖入`终端`回车即可执行自动打包脚本

4、执行后按需求选择打包版本（企业版、正式版、测试版、开发版）

5、如果执行脚本时出现如下错误是因为文件权限不足，只需对其授权777即可
```
-bash: /Users/candy/Desktop/AutoPackage.sh: Permission denied
```
执行如下授权命令即可（这里的`/Users/candy/Desktop/AutoPackage.sh`路径参考上面的）
```
chmod -R 777 /Users/candy/Desktop/AutoPackage.sh
```


### 打包脚本核心内容展示

```
# Clean操作
xcodebuild clean -${pro_clean} ${pro_name}.${pro_suffix} -scheme ${pro_name} -configuration ${pro_environ}
judgementLastIsSuccsess $? "Clean"

# Archive
xcodebuild archive -${pro_clean} ${pro_name}.${pro_suffix} -scheme ${pro_name} -archivePath ../${ipa_dir}/${pro_name}.xcarchive
judgementLastIsSuccsess $? "Archive"

# 导出IPA包
xcodebuild -exportArchive -archivePath ./${ipa_dir}/${pro_name}.xcarchive -exportOptionsPlist ./${d_filename}/autoplist/${pro_plist}.plist -exportPath ./${ipa_dir}
judgementLastIsSuccsess $? "导出IPA包"

# 上传到蒲公英
curl -F "file=@${ipa_path}" -F "uKey=${ukey}" -F "_api_key=${api_key}" -F "installType=2" -F "password=xznx1506" https://qiniu-storage.pgyer.com/apiv1/app/upload


# ============ 上传到App Store ============  
# 获取 altoolPath 上传工具
altoolPath="/Applications/Xcode.app/Contents/Applications/Application Loader.app/Contents/Frameworks/ITunesSoftwareService.framework/Versions/A/Support/altool"

# validate（验证）
"$altoolPath" --validate-app -f "$ipa_path" -u "$apple_id" -p "$apple_pwd" -t ios --output-format xml

# upload（上传）
"$altoolPath" --upload-app -f "$ipa_path" -u "$apple_id" -p "$apple_pwd" -t ios --output-format xml
# ============ 上传到App Store ============ 
 
```
### 如果不上传蒲公英或不上传App Store的话 注释下面两句话即可（如果没填写相关账号则不会执行上传操作）

```
uploadPGY
uploadAppStore
```
<div align="center">
<img src = "http://upload-images.jianshu.io/upload_images/2822163-23eb59c7072548bb.png" width = "300" height = "100" alt="图片名称" align = center />
</div>



