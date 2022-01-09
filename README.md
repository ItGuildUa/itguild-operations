# ItGuild Operations

GitOps репозиторий [itguild.org.ua](https://itguild.org.ua).

## Требования

 * [terraform](terraform.io)
 * [docker](https://www.docker.com/) (рекомендуется) 
   для [terraform](https://www.terraform.io/) [precommit](https://pre-commit.com/) [hooks](https://github.com/antonbabenko/pre-commit-terraform)

## Использование

Установите [precommit hooks](https://github.com/antonbabenko/pre-commit-terraform) согласно [официальной инструкции](https://github.com/antonbabenko/pre-commit-terraform#1-install-dependencies) 

Для сборки docker образа предоставлен [install-tfhooks.sh](./install-tfhooks.sh) скрипт.

```bash
terraform init

# Выполните проверки с помощью docker образа Антона Бабенко
docker run -v $(pwd):/lint -w /lint ghcr.io/antonbabenko/pre-commit-terraform:v1.62.3 run -a

# либо с помощью того что собрали сами с помощью ./install-tfhooks.sh
docker run -v $(pwd):/lint -w /lint pre-commit-terraform:v1.62.3 run -a

# желательно выполнить хотя бы минимальные проверки, если лень в pre-commit
terraform fmt -check
terraform validate

# выполните terraform plan, если у вас есть github token,
# или просто создайте PR в этот репозиторий
terrafrorm plan 

# добавьте изменения
git add .
git commit -m "new state"
# если настроили pre-commit и все статические анализаторы самостоятельно, 
# без докера, проверки выполнятся перед git commit
git push
```

При создании Pull Request github actions прокоментирует существующий план.

Пока состояние terraform'a так же хранится без блокировок в git репозитории, 
дополнительно проганяются проверки в github actions, там же применяется состояние через terraform apply.

## Примечание

Этот репозиторий не содержит github api token - публичный доступ к нему является безопасным.

## Лицензия

Это открытый проект для [IT Гильдии](https://itguild.org.ua), распространяется под [MIT Лицензией](LICENSE).
