# frozen_string_literal: true

require 'spec_helper'
require 'bolt_spec/plans'

describe 'terraform::apply' do
  include BoltSpec::Plans
  BoltSpec::Plans.init

  let(:params) do
    {
      'dir' => 'foo',
      'state' => 'foo',
      'state_out' => 'foo',
      'target' => 'foo',
      'var' => { 'foo' => 'bar' },
      'var_file' => 'foo'
    }
  end
  let(:bolt_config) { { 'modulepath' => RSpec.configuration.module_path } }
  let(:apply_result) { { 'stdout' => 'Terraform logs' } }
  let(:output_result) { { 'my' => 'output' } }

  it 'returns logs when $output is not set' do
    allow_task('terraform::apply').with_params(params).always_return(apply_result)
    result = run_plan('terraform::apply', params)
    expect(result.value[0].value).to eq(apply_result)
  end

  it 'returns output when $output is set' do
    plan_params = params.merge('return_output' => true)
    sub_task_params = { 'dir' => 'foo', 'state' => 'foo' }
    allow_task('terraform::apply').with_params(params).always_return(apply_result)
    allow_task('terraform::output').with_params(sub_task_params).always_return(output_result)
    result = run_plan('terraform::apply', plan_params)
    expect(result.value).to eq(output_result)
  end

  it 'refreshes state when $refresh_state is set' do
    plan_params = params.merge('refresh_state' => true)
    sub_task_params = { 'dir' => 'foo', 'state' => 'foo' }
    allow_task('terraform::apply').with_params(params).always_return(apply_result)
    allow_task('terraform::refresh').with_params(sub_task_params).always_return(apply_result)
    result = run_plan('terraform::apply', plan_params).value[0]
    expect(result.value).to eq(apply_result)
  end
end
