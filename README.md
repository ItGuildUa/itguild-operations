# ItGuild Operations

GitOps репозиторій [Гільдії IT Фахіфців](https://itguild.org.ua).

## Вимоги

 * [terraform](terraform.io)
 * [docker](https://www.docker.com/) (рекомендується) 
   для [terraform](https://www.terraform.io/) [precommit](https://pre-commit.com/) [hooks](https://github.com/antonbabenko/pre-commit-terraform)

## Використання

Вставіть [precommit hooks](https://github.com/antonbabenko/pre-commit-terraform) згідно [інструкції](https://github.com/antonbabenko/pre-commit-terraform#1-install-dependencies) 

Для збірки docker образу застосуйте [install-tfhooks.sh](./install-tfhooks.sh) скрипт.

```bash
# завантажте terraform провайдери
terraform init

# (опціонально) виконайте перевірки статичними аналізаторами, задопомогою docker образу Антона Бабенко
docker run -v $(pwd):/lint -w /lint ghcr.io/antonbabenko/pre-commit-terraform:v1.62.3 run -a

# або ж того що зібрали задопомогою ./install-tfhooks.sh
docker run -v $(pwd):/lint -w /lint pre-commit-terraform:v1.62.3 run -a

# Обов'язково виконайте перевірки перед Pull Request'ом
terraform fmt -check
terraform validate

# виконайте terraform plan, якщо у вас э github token організації,
# або ж просто зробіть Pull Request у цей репозиторій - відповідний Github Action прокоментує зміни
terrafrorm plan
```

При створенні Pull Request'a github actions прокоментує існуючий план.
Стан terraform'a зберігається, без блокувань, в цьому git репозиторії.

## Примітка

Тут не зберерігається github api token - тому публічний доступ є безпечним.

**Будьте обачні** - не опублікуйте github api token за жодних обставин.

## Ліцензія

Цей відкритий проект [Гільдії IT Фахіфців](https://itguild.org.ua) розповсюджується згідно [MIT Ліцензії](LICENSE).
