require 'spec_helper'

describe "the require all pattern" do

  it 'works' do
    expect(Autotimesheet::Source).not_to be_nil
  end

end