cd "$(DIRNAME "$0")"
git add *
read msg
git commit -m "$msg"
git push
