require 'spec_helper'
require 'phraseapp-in-context-editor-ruby'
require 'phraseapp-in-context-editor-ruby/key_names_cache'

describe PhraseApp::InContextEditor::KeyNamesCache do
  let(:key_names_cache){ PhraseApp::InContextEditor::KeyNamesCache.new(PhraseApp::InContextEditor::ApiWrapper.new) }

  before(:each) do
    PhraseApp::InContextEditor::Config.access_token = "test-token"
  end

  describe "#prefetched_key_names", vcr: {cassette_name: 'fetch list of keys filtered by key names', match_requests_on: [:method, :uri, :body]} do
    subject { key_names_cache.send(:prefetched_key_names) }

    before(:each) do
      PhraseApp::InContextEditor.config.cache_key_segments_initial = initial_segments
    end

    context "api returned a string" do
      let(:initial_segments) { ["foo"] }

      it { should include("foo") }
    end

    context "api returned a hash" do
      #{"bar" => "lorem"}
      let(:initial_segments) { ["bar"] }

      it { should include("bar.foo") }
    end

    context "api returned a nested hash" do
      #{"bar" => {"baz" => "ipsum", "def" => "lorem"}}
      let(:initial_segments) { ["nested"] }

      it { should include("nested.bar.baz") }
      it { should include("nested.bar.def") }
    end
  end

  describe "#covered_by_initital_caching?(key_name)" do
    let(:key_name_to_fetch) { "simple.form" }

    subject { key_names_cache.send(:covered_by_initial_caching?, key_name_to_fetch) }

    context "key starts with expression found in InContextEditor.cache_key_segments_initial" do
      before(:each) do
        PhraseApp::InContextEditor.config.cache_key_segments_initial = ["simple", "bar"]
      end

      it { is_expected.to be_truthy }

      context "is an exact match" do
        let(:key_name_to_fetch) { "simple" }

        it { is_expected.to be_truthy }
      end
    end

    context "key does not start with expression found in InContextEditor.cache_key_segments_initial" do
      before(:each) do
        PhraseApp::InContextEditor.config.cache_key_segments_initial = ["nope"]
      end

      it { is_expected.to be_falsey }
    end
  end
end
