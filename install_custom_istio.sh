if [[ $MYMOUNT == "" ]]
then
	echo MYMOUNT undefined
	exit 1
fi

$MYMOUNT/istio/out/linux_amd64/istioctl manifest install -f istio-de.yaml