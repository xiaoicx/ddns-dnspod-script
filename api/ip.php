<?php
    require 'IpLocation.php';
    use itbdw\Ip\IpLocation;
    
    //秘钥: WW91ciBjaGVzdCBiaWc=
    $p = "WW91ciBjaGVzdCBiaWc";

    $ip = filter_var($_GET['ip'],FILTER_VALIDATE_IP);
    $token = $_GET['e'];
    
    if (empty($ip) || empty($token)) {
        encodeErrorToJson("请参数丢失!","1007");
        exit(1);
    }

    if (!$ip) {
        encodeErrorToJson("IP 地址无效","1005");
        exit(1);
    }
    if ($token != $p) {
        encodeErrorToJson("无效请求!","1003");
        exit(1);
    }
    
    $IpLocation = @IpLocation::getLocation($ip);
    $newArryObj = @array(
                        "ip" => $ip,
                        "location" => $IpLocation,
                        "info" => array(
                            "state" => empty($IpLocation) == false ? "ok" : "error",
                            "code" => "1001"
                            )
                        );
    echo @json_encode($newArryObj,JSON_UNESCAPED_UNICODE);
?>

<?php
    function encodeErrorToJson($text,$code){
        echo @json_encode(array(
                "info" => $text,
                "code" => $code
            ));
    }
?>