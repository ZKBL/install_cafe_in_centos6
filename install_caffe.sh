mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
    curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-6.repo
    yum clean all && yum makecache
    yum update -y
    yum install gcc  -y
    yum install zlib zlib-devel openssl openssl-devel