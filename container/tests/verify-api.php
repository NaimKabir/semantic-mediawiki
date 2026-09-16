<?php
// Exercise Apache and SMW over HTTP, from within the running container.
function api( array $params ): array {
    $url = 'http://127.0.0.1/api.php?' . http_build_query( [ 'format' => 'json' ] + $params );
    $body = file_get_contents( $url, false, stream_context_create( [
        'http' => [ 'timeout' => 15 ],
    ] ) );
    if ( $body === false ) {
        throw new RuntimeException( 'HTTP request failed' );
    }
    $data = json_decode( $body, true, 512, JSON_THROW_ON_ERROR );
    if ( isset( $data['error'] ) ) {
        throw new RuntimeException( json_encode( $data['error'] ) );
    }
    return $data;
}
$info = api( [ 'action' => 'query', 'meta' => 'siteinfo', 'siprop' => 'extensions|general' ] );
$extensions = array_column( $info['query']['extensions'], 'version', 'name' );
if ( ( $extensions['SemanticMediaWiki'] ?? null ) !== getenv( 'SMW_VERSION' ) ) {
    throw new RuntimeException( 'SMW is missing or has the wrong version' );
}
if ( $info['query']['general']['generator'] !== 'MediaWiki ' . getenv( 'MEDIAWIKI_VERSION' ) ) {
    throw new RuntimeException( 'Unexpected MediaWiki version' );
}
$result = api( [ 'action' => 'ask', 'query' => '[[Has test value::Registry round trip works]]' ] );
if ( !isset( $result['query']['results']['SMW smoke test'] ) ) {
    throw new RuntimeException( json_encode( $result ) );
}
echo "HTTP extension registration and semantic annotation/query passed\n";
