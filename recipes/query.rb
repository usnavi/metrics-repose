if %w(stage prod perf01 qe01 qe02).any? { |e| e.include?(node.environment) }
  keystone_v2_credentials = Chef::EncryptedDataBagItem.load('blueflood', "repose_#{node.environment}")
  node.set['repose']['keystone_v2']['identity_username'] = keystone_v2_credentials['username']
  node.set['repose']['keystone_v2']['identity_password'] = keystone_v2_credentials['password']
end

node.set['repose']['cluster_ids'] = ['blueflood-query']

repose_peers = Array.new
node['repose']['query_servers'].each do |server|
  repose_peers.push({
    'cluster_id' => node['repose']['cluster_ids'].first,
    'id' => server.to_s,
    'hostname' => server.to_s,
    'port' => node['repose']['query']['container_port']
    })
  end
node.default['repose']['peers'] = repose_peers

node.set['repose']['endpoints'] = [{
    'cluster_id' => 'blueflood-query',
    'id' => 'blueflood-query',
    'protocol' => 'http',
    'hostname' => 'localhost',
    'root_path' => '',
    'port' => 2500
    }]

node.set['repose']['slf4j_http_logging']['id'] = 'query-repose-http-log'

node.set['repose']['keystone_v2']['white_list'] = %w(
  /blueflood-query\.wadl$
)
node.set['repose']['keystone_v2']['cache'] = {
    'timeout_variability' => 10,
    'token_timeout' => 600,
    'group_timeout' => 600,
    'endpoints_timeout' => 600
    }
node.set['repose']['tenant_handling']['send_all_tenant_ids'] = true
node.set['repose']['tenant_handling']['validate_tenant'] = {
    'url_extraction_regex' => '.*'
    }
node.set['repose']['tenant_handling']['send_tenant_id_quality'] = {
    'default' => '1.0',
    'roles' => '0.5',
    'uri' => '0.5'
    }
node.set['repose']['http_connection_pool']['chunked_encoding'] = false
node.set['repose']['dist_datastore']['port'] = 9012
node.set['repose']['dist_datastore']['cluster_id'] = ['blueflood-query']
node.set['repose']['ip_user']['cluster_id'] = ['all']
node.set['repose']['api_validator']['cluster_id'] = ['all']
node.set['repose']['api_validator']['wadl'] = 'blueflood-query.wadl'
node.set['repose']['api_validator']['dot_output'] = '/tmp/blueflood-query.wadl.dot'
node.set['repose']['api_validator']['enable_rax_roles'] = true
node.set['repose']['api_validator']['check_well_formed'] = false
node.set['repose']['api_validator']['check_grammars'] = true
node.set['repose']['api_validator']['check_elements'] = true
node.set['repose']['api_validator']['check_plain_params'] = true
node.set['repose']['api_validator']['do_xsd_grammar_transform'] = true
node.set['repose']['api_validator']['enable_pre_process_extension'] = true
node.set['repose']['api_validator']['remove_dups'] = true
node.set['repose']['api_validator']['xpath_version'] = '2'
node.set['repose']['api_validator']['xsl_engine'] = 'XalanC'
node.set['repose']['api_validator']['join_xpath_checks'] = false

node.set['repose']['rate_limiting']['cluster_id'] = ['all']
node.set['repose']['rate_limiting']['uri_regex'] = '/v[0-9.]+/(hybrid:)?[0-9]+/limits/?'
node.set['repose']['rate_limiting']['include_absolute_limits'] = true
node.set['repose']['rate_limiting']['global_limit_id'] = 'global'
node.set['repose']['rate_limiting']['global_limit_uri'] = '*'
node.set['repose']['rate_limiting']['global_limit_uri_regex'] = '.*'
node.set['repose']['rate_limiting']['global_limit_value'] = 1000
node.set['repose']['rate_limiting']['global_limit_unit'] = 'MINUTE'
node.set['repose']['rate_limiting']['limit_groups'] = [
  { 'id' => 'main',
    'groups' => 'IP_Standard',
    'default' => true,
    'limits' => [
      { 'id' => '/version/tenantId/*',
        'uri' => '/version/tenantId/*',
        'uri-regex' => '/v[0-9.]+/((hybrid:)?[0-9]+)/.+',
        'http-methods' => 'ALL',
        'unit' => 'MINUTE',
        'value' => 10000
      }
    ]
  },
  { 'id' => 'unlimited',
    'groups' => 'unlimited',
    'default' => false,
    'limits' => []
  }
]