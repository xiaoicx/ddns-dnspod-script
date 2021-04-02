<?php
    require 'IpLocation.php';
    use itbdw\Ip\IpLocation;
    
    $count = 0;
    $iparr = array();
    if(!empty($_SERVER["HTTP_X_FORWARDED_FOR"])){
        $realIp = $_SERVER["HTTP_X_FORWARDED_FOR"];
        $iparr[count($iparr)] = $realIp;
        $count++;
    }else {
        $realIp = "127.0.0.1";
    }
    if (!empty($_SERVER["HTTP_CLIENT_IP"])) {
        $clientIp = $_SERVER["HTTP_CLIENT_IP"];
        $iparr[count($iparr)] = $clientIp;
        $count++;
    }else{
        $clientIp = "127.0.01";
    }
    if (!empty($_SERVER["REMOTE_ADDR"])) {
        $remoteIp = $_SERVER["REMOTE_ADDR"];
        $iparr[count($iparr)] = $remoteIp;
        $count++;
    }else{
        $remoteIp = "127.0.0.1";
    }
    $IpLocals = getiplocation($iparr);
    $arrayObj = array(
                    "ips" => array(
                        "realIP" => $realIp,
                        "clientIP" => $clientIp,
                        "remoteIP" => $remoteIp
                    ),
                    "localtions" => $IpLocals,
                    "fmtInfo" => array(
                        "fmt" => $count,
                        "state" => $count <= 0 ? "error" : "ok")
                    );
    // echo "<pre>";
    echo json_encode($arrayObj,JSON_UNESCAPED_UNICODE);;
?>


<?php
    function getiplocation($arr){
        $newarr = array();
        foreach ($arr as $ip) {
            $newarr[count($newarr)] = IpLocation::getLocation($ip);
        }
        return $newarr;
    }
?>
