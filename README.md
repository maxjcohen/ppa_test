# ACIAH hepler scripts and ressources

## Install
```bash
sudo curl -Ssl -o /etc/apt/trusted.gpg.d/aciah.asc https://maxjcohen.github.io/ppa_test/ppa/KEY.asc
sudo echo "deb [signed-by=/etc/apt/trusted.gpg.d/aciah.asc] https://maxjcohen.github.io/ppa_test/ppa ./" > /etc/apt/sources.list.d/aciah.list
sudo apt update
sudo apt install aciah
```

## Build
See Makefile
