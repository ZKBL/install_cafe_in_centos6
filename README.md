# centos6 安装caffe
## **打开网络**

* 修改 `/etc/sysconfig/network-scripts/ifconfig-eth0 `
 将`ONBOOT=no` 修改为`ONBOOT=yes`

```
    DEVICE=eth0
    HWADDR=00:15:5D:4B:3C:1F
    TYPE=Ethernet
    UUID=a91ad2f2-db10-4799-b5e1-b5cb5fc8b3f4
    ONBOOT=yes
    NM_CONTROLLED=yes
    BOOTPROTO=dhcp
```
*`BOOTPROTO=dhcp`使用dhcp自动分配IP地址，可以修改为静态IP地址* 

* 重启网络服务
```bash
    service network restart 
```

## **换国内源并且安装epel源**

- 备份源
```bash
   mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
```
- 更换阿里云镜像源
```bash
    curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-6.repo
```

- 开启epel源
```bash
    curl -o /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-6.repo
```
- 清除并更新缓存
```bash
    yum clean all && yum makecache
```
- 更新系统
```bash
    yum update -y
```
## **编译安装python2.7**
- 安装GCC
```bash
    yum install gcc 
```
- 安装一些必要的库
```bash
    yum install zlib zlib-devel openssl openssl-devel
```
- 下载源码解压后进入到目录
```
    curl -O https://www.python.org/ftp/python/2.7.17/Python-2.7.17.tgz
    
    tar -zxvf ./Python-2.7.17.tgz
    cd ./Python-2.7.17
```
- 开始编译安装
```bash
    ./configure --enable-optimizations --enable-shared
    
    make && make altinstall
```
    *--enbale-optimizations 是开启优化选项*
    
    *altinstall 避免覆盖系统原来安装的python*

- 查看安装是否成功

```bash
    /usr/local/bin/python2.7 -V
``` 
*如果报错如下*
```bash
    /usr/local/bin/python2.7: error while loading shared libraries: libpython2.7.so.1.0: cannot open shared object file: No such file or directory
```
*执行下面命令*
```bash
    echo "/usr/local/lib" >> /etc/ld.so.conf

    ldconfig
```

- 替换系统默认python版本
```bash
    mv /usr/bin/python /usr/bin/python2.6.6

    ln -s /usr/local/bin/python2.7 /usr/bin/python
```
- 解决yum不支持python2.7 
    执行下面命令
```bash
    sed -i 's/python/python2.6.6/' /usr/bin/yum
```
或者直接vi编辑`/usr/bin/yum`，把头部换成'#!/usr/bin/python2.6.6'

- 安装pip
```bash
    python -m ensurepip
```
## **安装cuda**
虚拟机没有支持的显卡，暂时跳过,只安装CPU模式

## **安装Blas**
caffe 支持三种Blas，这里使用OpenBlas

```bash
    # 安装git
    yum install git 
    git clone https://github.com/xianyi/OpenBLAS.git
    cd OpenBLAS
    make  
    make install 
```
```bash
    make[1]: *** [sgemm_kernel.o] Error 1
    make[1]: *** Waiting for unfinished jobs....
    make[1]: Leaving directory `/root/OpenBLAS/kernel'
    make: *** [libs] Error 1
```
*如果出现以上错误，可以安装clang，使用clang编译*
```bash   
    yum install clang
    make clean 
    make CC=clang
    make install
```
## 安装boost库

```bash
    # boost库需要安装g++
    yum install gcc-c++
    curl -O  https://nchc.dl.sourceforge.net/project/boost/boost/1.55.0/boost_1_55_0.tar.gz
    tar -zxvf ./boost_1_55_0.tar.gz
    cd boots_1_55_0
    ./bootstrap.sh
    ./b2
    ./b2 install
```
运行./b2 install命令，默认安装在/usr/local/lib目录下，头文件在/usr/local/include/boost目录下

## 安装OpenCV


```bash
    # 需要安装 unzip 和cmake
    yum install unzip cmake

    curl -O https://nchc.dl.sourceforge.net/project/opencvlibrary/opencv-unix/2.4.9/opencv-2.4.9.zip

    unzip ./opencv-2.4.9
    cd opencv-2.4.9
    cmake CMakeLists.txt
    make 
    make install 
```

## 安装caffe依赖
- yum安装
```bash 
    yum install protobuf-devel leveldb-devel snappy-devel  hdf5-devel
```
- 源码编译安装


```bash
    #我安装时使用curl 出现错误，需要安装wget使用wget下载
    yum install wget
    # glog
    wget -O glog-0.3.3.tar.gz https://codeload.github.com/google/glog/tar.gz/v0.3.3
    tar zxvf glog-0.3.3.tar.gz
    cd glog-0.3.3
    ./configure
    make && make install
    
    # gflags
    ## 需要使用cmake3 
    yum
    wget -O https://github.com/schuhschuh/gflags/archive/master.zip
    unzip master.zip
    cd gflags-master
    
    export CXXFLAGS="-fPIC" && cmake3 ./CMakeLists.txt
    make && make install
    
    # lmdb
    git clone https://github.com/LMDB/lmdb
    cd lmdb/libraries/liblmdb
    make && make install
```
## 安装caffe

```bash
    # 下载源码
    git clone https://github.com/BVLC/caffe.git
    cd caffe

    # 安装python依赖项目
    pip install 'six>=1.3'
    easy_install -U distribute
    pip install pillow

    cd ./python
    for req in $(cat requirements.txt); do pip install $req; done

    # 返回caffe目录下安装
    cd ../
    mkdir build && cd build
    cmake3 ../
    make && make install

```
虚拟机下无法使用cuda make runtest