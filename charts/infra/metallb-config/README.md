# metallb-config

![Version: 1.0.0](https://img.shields.io/badge/Version-1.0.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

Generic MetalLB configuration (multiple pools, ads)

## Requirements

| Repository          | Name   | Version |
| ------------------- | ------ | ------- |
| file://../../common | common | 0.1.0   |

## Values

| Key               | Type   | Default | Description                 |
| ----------------- | ------ | ------- | --------------------------- |
| commonAnnotations | object | `{}`    |                             |
| commonLabels      | object | `{}`    |                             |
| pools             | list   | `[]`    | IPAddressPool definitions   |
| l2Advertisements  | list   | `[]`    | L2Advertisement definitions |
