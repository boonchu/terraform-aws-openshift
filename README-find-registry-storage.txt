# oc get pods

$ oc exec docker-registry-2-gbvff df /registry
Filesystem     1K-blocks  Used Available Use% Mounted on
/dev/xvdcp      20511312 45080  20449848   1% /registry

$ awless list instances --filter name="OpenShift Master"
|        ID ▲         |      ZONE       |       NAME       |  STATE  |   TYPE    |   PUBLIC IP    |  PRIVATE IP  |  UPTIME  |  KEYPAIR  |
|---------------------|-----------------|------------------|---------|-----------|----------------|--------------|----------|-----------|
| i-00c4b68eb7da129b0 | ap-southeast-1a | OpenShift Master | running | m4.xlarge | 18.136.160.211 | 172.10.1.198 | 25 hours | openshift |

$ awless list volumes --filter name="kubernetes-dynamic-pvc-"
|         ID ▲          |               NAME               | TYPE |   STATE   | SIZE | ENCRYPTED | CREATED  |      ZONE       |
|-----------------------|----------------------------------|------|-----------|------|-----------|----------|-----------------|
| vol-012790d43a3014abc | kubernetes-dynamic-pvc-5be42c63- | gp2  | available | 5G   | false     | 7 days   | ap-southeast-1a |
|                       | b353-11e9-8849-026f8b0bbf30      |      |           |      |           |          |                 |
| vol-09218975b196497cc | kubernetes-dynamic-pvc-8b08b22f- | gp2  | in-use    | 20G  | false     | 20 hours | ap-southeast-1a |
|                       | b828-11e9-bf58-02222844b110      |      |           |      |           |          |                 |
| vol-0d8b96695ae736ecf | kubernetes-dynamic-pvc-65f934cf- | gp2  | available | 20G  | false     | 6 days   | ap-southeast-1a |
|                       | b359-11e9-8849-026f8b0bbf30      |      |           |      |           |          |                 |

$ tf-ebs-attach show i-00c4b68eb7da129b0  kubernetes-dynamic-pvc-8b08b22f-b828-11e9-bf58-02222844b110 vol-09218975b196497cc registry-storage /dev/xvdcp | jq -r .
{
  "aws_volume_attachment.registry-storage": {
    "type": "aws_volume_attachment",
    "depends_on": [
      "aws_ebs_volume.kubernetes-dynamic-pvc-8b08b22f-b828-11e9-bf58-02222844b110"
    ],
    "primary": {
      "id": "vai-782222304",
      "attributes": {
        "device_name": "/dev/xvdcp",
        "id": "vai-782222304",
        "instance_id": "i-00c4b68eb7da129b0",
        "volume_id": "vol-09218975b196497cc"
      },
      "meta": {},
      "tainted": false
    },
    "deposed": [],
    "provider": ""
  }
}
