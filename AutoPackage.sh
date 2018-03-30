#!/bin/bash
# iOS AutoPackage Shell Script
# Author:  阿唯不知道 <90candy.com @ gmail.com>
# 脚本使用方法：直接把脚本拖入终端 然后回车键即可执行
# 注意1：将plist文件夹、打包脚本放到项目的根目录
# 注意2：不要在等号两边加空格
# 注意3：请先正确配置需要打包的项目后再来（如果连手动打包都失败的话自动打包肯定也不会成功）

############################ 参数配置 ###################################

# 项目全称（一般为BaseProject.xcworkspace 或者 BaseProject.xcodeproj）
# 注意，使用cocoapods的一般都填写 xxx.xcworkspace 这种格式
pro_full_name="BaseProject.xcworkspace"

# 自动上传蒲公英(uKey、_api_key)获取地址https://www.pgyer.com/doc/api#uploadApp
api_key="" # 不上传可不填
ukey="" # 不上传可不填

# 自动上传苹果商店(不上传可不填)
# 苹果开发者账号
apple_id=""
apple_pwd=""
############################ 参数配置 ###################################



printf "
#######################################################################
#                              阿唯不知道
#                       不要因为骄傲而不屑于抄袭
#         更多内容请访问 https://www.jianshu.com/u/0f7d26d766f4
#######################################################################
"
# 判断配置是否为空
if [ -z "$pro_full_name" ]; then
echo "${CWARNING}项目全称不能为空 ${CEND}"
exit
fi

myarray=(${pro_full_name//./ })
for var in ${array[@]}
do
echo $var
done
pro_name=${myarray[0]}
pro_suffix=${myarray[1]}
# 判断项目全称是否配置正确
if [ "$pro_suffix" != "xcworkspace" ] && [ "$pro_suffix" != "xcodeproj" ]; then
echo "${CWARNING}项目名称配置错误，请正确配置project_full_name，如：Project.xcworkspace 或 BaseProject.xcodeproj类型${CEND}"
exit
fi

# 打包导出类型(默认为苹果商店正式发布版)
pro_plist="AppStoreExportOptions"

while :; do
  printf "
选择你需要打包的类型（企业版只有企业账号才行哦！）
\t${CMSG}1${CEND}. Enterprise(企业版)
\t${CMSG}2${CEND}. App Store(正式版)
\t${CMSG}3${CEND}. AdHoc(测试版)
\t${CMSG}4${CEND}. Developers(开发版)
\t${CMSG}q${CEND}. 退出打包脚本
"
  read -p "请输入打包类型: " Number
  if [[ ! $Number =~ ^[1-4,q]$ ]]; then
    echo "${CFAILURE}输入错误! 只允许输入 1 ~ 4 和 q${CEND}"
  else
    case "$Number" in
    1)
      pro_plist=EnterpriseExportOptions
      break
      ;;
    2)
      pro_plist=AppStoreExportOptions
      break
      ;;
    3)
      pro_plist=AdHocExportOptions
      break
      ;;
    4)
      pro_plist=DevelopmentExportOptions
      break
      ;;
    q)
      exit
      ;;
    esac
  fi
done

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
    if [ $1 -le 0 ]; then
    echo "============ 请检查项目是否能正常手动打包并导出ipa文件 ======="
    exit
    fi
    if [ $1 -gt 59 ]; then
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
if [ $pro_suffix == xcworkspace ]; then
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
    echo "============ ${d_filename} AppStore - 上传结束 ======="
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



