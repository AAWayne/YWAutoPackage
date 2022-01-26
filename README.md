# YWAutoPackage - iOS项目自动打包脚本

>⚠️注意：
>
> 你的项目第一次必须手动打包成功后再能正常使用脚本，因为Xcode手动打包会把打包所需资料准备齐全

### 使用方法：

1、将`YWAutoPackage文件夹`直接拖到`桌面`后

2、配置打开编辑`YWAutoPackage.sh`中的配置相关参数

3、再将`YWAutoPackage.sh`脚本文件拖入`终端`回车即可执行自动打包脚本

4、执行后按需求选择打包版本（开发版、测试版、正式版、企业版）

5、如果执行脚本时出现如下错误是因为文件权限不足，只需对其授权777即可
```
-bash: /Users/candy/Desktop/YWAutoPackage.sh: Permission denied
```
执行如下授权命令即可（这里的路径可复制拖入终端时的路径）
```
chmod -R 777 YWAutoPackage.sh 文件绝对路径
```


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
<img src = "https://upload-images.jianshu.io/upload_images/2822163-1b59ac9d4417b718.png" align = center />
</div>

<div align="center">
<img src = "http://upload-images.jianshu.io/upload_images/2822163-23eb59c7072548bb.png" width = "300" height = "100" alt="图片名称" align = center />
</div>
