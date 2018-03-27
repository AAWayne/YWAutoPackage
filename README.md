# AutoPackage
iOS项目自动打包脚本

### 使用方法：
1、将脚本和autoplist文件夹拖入项目的根目录后

2、再将AutoPackage.sh脚本文件拖入终端回车即可执行自动打包脚本

### 自己使用的打包脚本，这里配置为企业版打包环境，其他版本自行修改plist配置(pro_plist=EnterpriseExportOptions)

* 企业环境 - EnterpriseExportOptions
* 苹果商店 - AppStoreExportOptions
* 开发环境 - AdHocExportOptions
* 开发环境 - DevelopmentExportOption

###  若是需要上传到蒲公英，追加以下代码

```
# 自动上传蒲公英(这里的 uKey、_api_key)获取地址为 https://www.pgyer.com/doc/api#uploadApp
################## 配置上传参数 _api_key、uKey Start ########
pgy_api_key="650b285e9ba 这里自己去查你的_api_key c94d58ac53a"
pgy_ukey="1afad5df91 这里自己去查你的_ukey f7305e29"
################## 配置蒲公英上传参数 End ####################
# 开始上传
echo "============ 正在上传 ${d_filename} 到蒲公英 ======="
ipa_file_path="./${pro_name}.ipa"
curl -F "file=@${ipa_file_path}" -F "uKey=${pgy_ukey}" -F "_api_key=${pgy_api_key}" https://qiniu-storage.pgyer.com/apiv1/app/upload
echo "============ 上传结束 ======="

# 上传结束时间
upload_end_time=$(date +%s)
# 计算上传时间(秒：s)
upload_time=$[$upload_end_time - $end_time]
#调用时间转换函数
timeTransformation $upload_time "上传蒲公英"
```

![](http://upload-images.jianshu.io/upload_images/2822163-089602958ae7072a.png)



