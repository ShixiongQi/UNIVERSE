if [[ $MYMOUNT == "" ]]
then
	echo MYMOUNT not defined
	exit 1
fi
$MYMOUNT/istio/out/linux_amd64/istioctl x uninstall --purge