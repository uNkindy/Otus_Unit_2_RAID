#!/bin/bash

#устанавливаем пакеты для создадния программных рейдов mdamd
yum install -y mdadm
yum install -y gdisk

#создаем программный рейд 10 из блочных устройств /dev/sd[e-h]
mdadm --create --verbose /dev/md/raid10 --level=10 --raid-devices=4 /dev/sde /dev/sdf /dev/sdg /dev/sdh 

#создаем раздел gpt на рейде 10 размером в 1Гб GPT
sgdisk -n 1:0:1G /dev/md/raid10

#записываем информацию о рейде в /etc/mdadm/mdadm.conf
mkdir /etc/mdadm
mdadm --detail --scan > /etc/mdadm/mdadm.conf

#делаем 5 партиций на диске sdc по 100 Мб GPT
for i in {1..5} ; do
sgdisk -n ${i}:0:+100M /dev/sdc ;
done

#создаем точку монтирования в /mnt/raid10, форматируем созданный раздел и монтируем рейд
mkdir /mnt/raid10
mkfs /dev/md/raid10p*
sleep 5
mount /dev/md/raid10p1 /mnt/raid10

#записываем информацию о рейде в fstab для автматического запуска и монтирования рейда при загрузке виртуальной машины
echo "/dev/md/raid10p1 /mnt/raid10 ext4 defaults 1 2" > /etc/fstab


