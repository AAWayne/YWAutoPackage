# AutoPackage - iOS项目自动打包脚本
### 使用方法：
1、将`AutoPackage.sh` 脚本和`autoplist文件夹`拖入`项目根目录`后

2、配置打开编辑`AutoPackage.sh`中的配置参数（若只打包，则只需配置`pro_full_name`即可）

3、再将`AutoPackage.sh`脚本文件拖入`终端`回车即可执行自动打包脚本

4、执行后按需求选择打包版本（企业版、正式版、测试版、开发版）

### 打包脚本核心内容展示

```
# 开始打包操作
# 开始时间（用于计算打包脚本执行时间）
begin_time=$(date +%s)
# 获取系统时间
date_string=`date +"%Y-%m-%d_%H-%M-%S"`
# 获取脚本当前所在目录(即上级目录绝对路径)
root_dir=$(cd "$(dirname "$0")"; pwd)/
# 切换到当前脚本的工作目录
cd ${root_dir}
# 获取当前目录名称（父文件夹名字）
d_filename=${PWD##*/} # 打印当前所在目录(basename `pwd`) 或 echo ${d_filename}
# 时间转换函数（秒转分钟）
timeTransformation()
{
if [ $1 -gt 59 ]
then
t_min=$[$1 / 60]
t_second=$[$1 % 60]
echo "============ 本次$2用时：${t_min}分${t_second}秒 ======="
else
echo "============ 本次$2用时：$1秒 ======="
fi
}
echo "============ ${d_filename} 打包开始 ======="
# 默认Release版
pro_environ=Release
# 如果没有使用cocoapods 反之if会处理
pro_clean=project
if [ $pro_suffix == xcworkspace ]
then
pro_clean=workspace
fi

# Clean操作
xcodebuild clean -${pro_clean} ${pro_name}.${pro_suffix} -scheme ${pro_name} -configuration ${pro_environ}
# 创建存放 archive和IPA 的文件夹
cd ../
ipa_dir=${d_filename}_${date_string}
mkdir ${ipa_dir}
cd ./${d_filename}
# Archive
xcodebuild archive -${pro_clean} ${pro_name}.${pro_suffix} -scheme ${pro_name} -archivePath ../${ipa_dir}/${pro_name}.xcarchive
cd ../
# 导出IPA包
xcodebuild -exportArchive -archivePath ./${ipa_dir}/${pro_name}.xcarchive -exportOptionsPlist ./${d_filename}/autoplist/${pro_plist}.plist -exportPath ./${ipa_dir}
# 切换到ipa目录去删除${pro_name}.xcarchive包
cd ./${ipa_dir}
rm -r ${pro_name}.xcarchive
# ipa文件路径（用于上传）
ipa_path="./${pro_name}.ipa"
echo "============ ${d_filename} 打包完成 ======="
# 打包结束时间
end_time=$(date +%s)
# 计算打包时间(秒：s)
cost_time=$[$end_time - $begin_time]
#调用时间转换函数
timeTransformation $cost_time "打包"


########################## 上传蒲公英 #################################
uploadPGY()
{
# 判断配置是否为空，空则代表不上传
if [ -z "$api_key" ] || [ -z "$ukey" ]; then
return
fi
# 上传开始时间
upload_start_time=$(date +%s)
# 开始上传
echo "============ 正在上传 ${d_filename} 到 蒲公英 ======="
curl -F "file=@${ipa_path}" -F "uKey=${ukey}" -F "_api_key=${api_key}" https://qiniu-storage.pgyer.com/apiv1/app/upload
echo "============ 上传结束 ======="
# 上传结束时间
upload_end_time=$(date +%s)
# 计算上传时间(秒：s)
upload_time=$[$upload_end_time - $upload_start_time]
#调用时间转换函数
timeTransformation $upload_time "上传蒲公英"
}
########################## 上传苹果商店 #################################
uploadAppStore()
{
# 判断配置是否为空，空则代表不上传
if [ -z "$apple_id" ] || [ -z "$apple_pwd" ]; then
return
fi
# 上传开始时间
upload_start_time=$(date +%s)
# 开始上传
echo "============ 准备上传 ${d_filename} 到 AppStore ======="
altoolPath="/Applications/Xcode.app/Contents/Applications/Application Loader.app/Contents/Frameworks/ITunesSoftwareService.framework/Versions/A/Support/altool"
# validate（验证）
echo "============ ${d_filename} 正在验证IPA包 ======="
"$altoolPath" --validate-app -f "$ipa_path" -u "$apple_id" -p "$apple_pwd" -t ios --output-format xml
# 上传
echo "============ ${d_filename} 验证结束，正在上传中 ======="
"$altoolPath" --upload-app -f "$ipa_path" -u "$apple_id" -p "$apple_pwd" -t ios --output-format xml
echo "============ ${d_filename} AppStore - 上传完成 ======="
# 上传结束时间
upload_end_time=$(date +%s)
# 计算上传时间(秒：s)
upload_time=$[$upload_end_time - $upload_start_time]
#调用时间转换函数
timeTransformation $upload_time "上传App Store"
}

# 如果不上传蒲公英或不上传App Store的话 注释下面两句话即可（如果没填写相关账号则不会执行上传操作）
uploadPGY
uploadAppStore
```
<div align="center">
<img src = "http://upload-images.jianshu.io/upload_images/2822163-23eb59c7072548bb.png" width = "300" height = "100" alt="图片名称" align = center />
</div>



