if [[ $1 -eq 0 ]]
then
  rm /etc/ld.so.conf.d/ovsrpro.conf
  ldconfig
fi
