https://bugzilla.redhat.com/show_bug.cgi?id=1651632

oc describe oauthclient openshift-console
oc get secret console-oauth-config -o=jsonpath='{.data.clientSecret}' -n openshift-console | base64 --decode
oc describe configmap console-config -n openshift-console
oc delete --all pods -n openshift-console
