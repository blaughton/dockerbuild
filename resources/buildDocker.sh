#!/bin/sh

#git@github.com:blaughton/dockerbuild.git

keyId="GitHub-Blaughton-"
version=latest
branch="master"

while getopts "r:v:" OPTION; do
	case $OPTION in
		r)
			repo=$OPTARG
			;;
		v)
			version=$OPTARG
			;;
		k)
			keyID="${OPTARG}-"
			;;
		b)
			branch="${OPTARG}-"
			;;
		*)
			echo "Invalid Option: $OPTION"
			;;
	esac
done

if [ -z "$repo" -o -z "$version" ]; then
	echo "Missing either repo or verions"
	exit 1
fi

echo "Reop: $repo"
echo "Vers: $version"
project=`echo $repo | cut -f2 -d/ | cut -f1 -d.`

echo $project
aws secretsmanager get-secret-value --region us-east-1 --secret-id GitHub-Blaughton-PublicKey | jq '. | .SecretString' | sed 's/"//g' > /root/.ssh/id_rsa.pub
aws secretsmanager get-secret-value --region us-east-1 --secret-id GitHub-Blaughton-PrivateKey | jq '. | .SecretString' | sed 's/"//g' | sed 's/\\n/\n/g' > /root/.ssh/id_rsa
chmod 600 /root/.ssh/id_rsa.pub /root/.ssh/id_rsa
ssh-keyscan github.com >> ~/.ssh/known_hosts

mkdir -p /tmp/workspace
cd /tmp/workspace
git clone $repo
cd $project
git checkout $branch

if [ "$branch" != "master" ]; then
    localTag="$project:$branch-$version"
else
    localTag="$project:$version"
fi

docker build -t $localTag .
remoteTag="800446947915.dkr.ecr.us-east-1.amazonaws.com/$localTag"
docker tag $localTag $remoteTag

$(aws ecr get-login --region us-east-1 | sed 's/-e none //')
aws ecr create-repository --repository-name $project --region us-east-1
docker push $remoteTag
