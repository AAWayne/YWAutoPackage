# iOS AutoPackage Script
# Author: 阿唯不知道
# 脚本使用方法：直接把脚本拖入终端 然后回车键即可执行
# 注意1：将plist文件夹、打包脚本放到项目的根目录
# 注意2：不要在等号两边加空格

################## 配置打包参数 Start ####################
# 项目名称（如 BaseProject.xcworkspace 则填写 BaseProject ）
pro_name=BaseProject
# 是否使用了cocoapods(是就填xcworkspace， 没有使用就填xcodeproj)
pro_suffix=xcworkspace
# 是Debug版本还是Release版本,填相应的就行了
pro_environ=Release
# 根据具体需求去设置相应的plist文件（这里为企业版）
pro_plist=EnterpriseExportOptions
#其他打包环境请配置如下名称：
# EnterpriseExportOptions - 企业版环境
# AppStoreExportOptions - 发布App Store的
# AdHocExportOptions - 开发环境
# DevelopmentExportOptions - 开发环境
################## 配置打包参数 End ####################

# 以下无需修改，不懂的请慎改
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
echo "============ ${d_filename} 打包完成 ======="
# 打包结束时间
end_time=$(date +%s)
# 计算打包时间(秒：s)
cost_time=$[$end_time - $begin_time]
#调用时间转换函数
timeTransformation $cost_time "打包"

## 自动上传蒲公英(这里的 uKey、_api_key)获取地址为 https://www.pgyer.com/doc/api#uploadApp
################### 配置上传参数 _api_key、uKey Start ########
#pgy_api_key="650b285e9ba 这里自己去查你的_api_key c94d58ac53a"
#pgy_ukey="1afad5df91 这里自己去查你的_ukey f7305e29"
################### 配置蒲公英上传参数 End ####################
## 开始上传
#echo "============ 正在上传 ${d_filename} 到蒲公英 ======="
#ipa_file_path="./${pro_name}.ipa"
#curl -F "file=@${ipa_file_path}" -F "uKey=${pgy_ukey}" -F "_api_key=${pgy_api_key}" https://qiniu-storage.pgyer.com/apiv1/app/upload
#echo "============ 上传结束 ======="
#
## 上传结束时间
#upload_end_time=$(date +%s)
## 计算上传时间(秒：s)
#upload_time=$[$upload_end_time - $end_time]
##调用时间转换函数
#timeTransformation $upload_time "上传蒲公英"

