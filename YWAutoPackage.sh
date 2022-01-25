#!/bin/bash
# iOS AutoPackage Shell Script
# Author:  阿唯不知道 <90candy.com @ gmail.com>
# ⚠️⚠️使用方法：将脚本文件夹放置在桌面，参数配置好之后直接把脚本拖入终端 然后回车键即可执行
# ⚠️⚠️注意1：由于此脚本不涉及证书及描述文件相关配置，所以需手动打包成功后才能使用此脚本
############################ 参数配置 ###################################

# 项目路径(文件夹绝对路径)
pro_path="/Users/xxx/BaseProject"
# 项目全称（一般为BaseProject.xcworkspace 或者 BaseProject.xcodeproj）
pro_full_name="BaseProject.xcworkspace"
# 默认 Release 版，也可配置为 Debug
pro_environ=Release

# ⚠️⚠️自动上传蒲公英(uKey、_api_key)获取地址https://www.pgyer.com/doc/api#uploadApp
api_key="" # 不上传则不填
ukey=""  # 不上传则不填
pgy_installType=1   # 1、公开发布 2、密码安装
pgy_password=""     # 如果设置了密码安装则需要密码

## ⚠️⚠️自动上传苹果商店 - 苹果开发者账号与密码
apple_id="" # 不上传则不填
apple_pwd="" # 不上传则不填
############################ 参数配置 ###################################


printf "
#######################################################################
#                     自动打包脚本 4.0 版本
#                          阿唯不知道
#                    不要因为骄傲而不屑于抄袭
#            更多内容请访问 https://90candy.github.io
#######################################################################
"

# 判断配置是否为空
if [ -z "${pro_full_name}" ]; then
echo "${CWARNING}⚠️项目全称不能为空 ${CEND}"
exit
fi

# 分割取得 项目名称 & 项目后缀
myarray=(${pro_full_name//./ })
for var in ${array[@]}
do
echo $var
done
pro_name=${myarray[0]}
pro_suffix=${myarray[1]}

# 判断项目全称是否配置正确
if [ "${pro_suffix}" != "xcworkspace" ] && [ "${pro_suffix}" != "xcodeproj" ]; then
echo "${CWARNING}⚠️项目名称配置错误，请正确配置project_full_name，如：BaseProject.xcworkspace 或 BaseProject.xcodeproj类型${CEND}"
exit
fi

# 打包导出类型(根据 plist 文件决定)
plist_name=""

while :; do
  printf "
选择你的打包版本类型：
   ${CMSG}1${CEND}.Developers(开发版)
   ${CMSG}2${CEND}.App Store(正式版)
   ${CMSG}3${CEND}.AdHoc(测试版)
   ${CMSG}4${CEND}.Enterprise(企业版)
   ${CMSG}q${CEND}.退出打包脚本\n
"
  read -p "请输入打包类型: " number
  if [[ ! ${number} =~ ^[1-4,q]$ ]]; then
    echo "${CFAILURE}⚠️输入错误! 只允许输入 1 ~ 4 和 q${CEND}"
  else
    case "$number" in
    1)
      plist_name="DevelopmentExportOptions.plist"
      break
      ;;
    2)
      plist_name="AppStoreExportOptions.plist"
      break
      ;;
    3)
      plist_name="AdHocExportOptions.plist"
      break
      ;;
    4)
      plist_name="EnterpriseExportOptions.plist"
      break
      ;;
    q)
      exit
      ;;
    esac
  fi
done

# 根据需求判断上一步是否执行成功，传入执行结果：$? "执行步骤名"
judgementLastIsSuccsess() {
    if [ $1 -eq 0 ]; then
    echo -e "\n⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️ $2 操 作 成 功 ! ⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️\n"
    else
    echo -e "\n😭😭😭😭😭😭😭😭 $2操作失败，终止脚本 ! 😭😭😭😭😭😭😭😭\n"
    exit
    fi
}

# 时间转换函数（秒转分钟）
timeTransformation()
{
    if [ $1 -le 0 ]; then
    echo "============ ⚠️请检查项目是否能正常手动打包并导出ipa文件 ======="
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

# 打包开始时间（用于计算打包脚本执行时间）
begin_time=$(date +%s)
# 获取系统时间
date_string=`date +"%Y-%m-%d~%H.%M.%S"`

# 获取脚本当前所在目录(即上级目录绝对路径)
root_dir=$(cd "$(dirname "$0")"; pwd)
# IPA 文件导出时使用的 plist 文件路径
plist_path="${root_dir}/ExportOptions/${plist_name}"

# 切换到当前脚本的工作目录
cd ${root_dir}

# 所有打包文件导出时的临时存放目录（IPA、Achieve）
temp_path="${root_dir}/ExportIPAFile"
if [ ! -d ${temp_path} ]; then
   mkdir -p ${temp_path}
fi

# 切换到 temp_path 目录去创建存放 Archive 和 IPA 的文件夹
cd ${temp_path}
ipa_dir="${pro_name}${date_string}"
mkdir ${ipa_dir}

# 切换到项目根目录开始打包操作
cd "${pro_path}"

echo "============ ${pro_name} 打包开始 ======="

# 如果没有使用cocoapods 反之if会处理
pro_clean=project
if [ ${pro_suffix} == "xcworkspace" ]; then
pro_clean=workspace
fi

# 先组装 archive_path、ipa_path，用于导出 ipa 和 上传
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

# 打包结束时间
end_time=$(date +%s)
# 计算打包时间(秒：s)
cost_time=$[${end_time} - ${begin_time}]
# 调用时间转换函数
timeTransformation ${cost_time} "打包"

echo "============ ${pro_name} 自动打包完成 ======="

# 打开 当前的 ipa 存放文件夹
open ${temp_path}/${ipa_dir}

########################## 上传蒲公英 #################################
uploadPGY()
{
    # 判断配置是否为空，空则代表不上传
    if [ -z "${api_key}" ] || [ -z "${ukey}" ]; then
    echo "============ 请先配置蒲公英的 api_key & ukey ======="
    return
    fi
    # 上传开始时间
    upload_start_time=$(date +%s)
    # 开始上传
    echo "============ 正在上传 ${pro_name} 到 蒲公英 ======="
curl -F "file=@${ipa_path}" -F "uKey=${ukey}" -F "_api_key=${api_key}" -F "installType=${pgy_installType}" -F "password=${pgy_password}" https://qiniu-storage.pgyer.com/apiv1/app/upload
    judgementLastIsSuccsess $? "上传蒲公英"
    echo "============ 上传结束 ======="
    # 上传结束时间
    upload_end_time=$(date +%s)
    # 计算上传时间(秒：s)
    upload_time=$[${upload_end_time} - ${upload_start_time}]
    # 调用时间转换函数
    timeTransformation ${upload_time} "上传蒲公英"
}

########################## 上传苹果商店 #################################
uploadAppStore()
{
    # 判断配置是否为空，空则代表不上传
    if [ -z "${apple_id}" ] || [ -z "${apple_pwd}" ]; then
    echo "============ 请先配置苹果商店的 apple_id & apple_pwd ======="
    return
    fi
    # 上传开始时间
    upload_start_time=$(date +%s)
    # 开始上传
    echo "============ 准备上传到 AppStore ======="
    altoolPath="/Applications/Xcode.app/Contents/Applications/Application Loader.app/Contents/Frameworks/ITunesSoftwareService.framework/Versions/A/Support/altool"
    # validate（验证）
    echo "============ 正在验证IPA包 ======="
    "${altoolPath}" --validate-app -f "${ipa_path}" -u "${apple_id}" -p "${apple_pwd}" -t ios --output-format xml
    judgementLastIsSuccsess $? "验证IPA包"
    # 上传
    echo "============ 验证结束，正在上传中 ======="
    "${altoolPath}" --upload-app -f "${ipa_path}" -u "${apple_id}" -p "${apple_pwd}" -t ios --output-format xml
    judgementLastIsSuccsess $? "上传App Store"
    echo "============ AppStore 上传结束 ======="
    # 上传结束时间
    upload_end_time=$(date +%s)
    # 计算上传时间(秒：s)
    upload_time=$[${upload_end_time} - ${upload_start_time}]
    # 调用时间转换函数
    timeTransformation ${upload_time} "上传App Store"
}

if [ "${plist_name}"x = "AppStoreExportOptions.plist"x ]; then
uploadAppStore
else
uploadPGY
fi





