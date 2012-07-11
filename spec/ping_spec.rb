require "spec_helper"

describe MassiveSitemap do
  describe ".ping" do
    let(:url) { "http://www.example.com" }

    describe "verify_and_escape" do
      it { MassiveSitemap.verify_and_escape("example.com/test").should == "http%3A%2F%2Fexample.com%2Ftest" }
      it { MassiveSitemap.verify_and_escape("http://example.com/test").should == "http%3A%2F%2Fexample.com%2Ftest" }
      it { MassiveSitemap.verify_and_escape("https://example.com/test").should == "https%3A%2F%2Fexample.com%2Ftest" }

      it "raise if invalid url" do
        expect do
          MassiveSitemap.verify_and_escape("example.com/")
        end.to raise_error URI::InvalidURIError
      end
    end

    describe "ping" do
      it "calles google and ask" do
        MassiveSitemap.should_receive(:open).twice()
        MassiveSitemap.ping(url, [:google, :ask])
      end

      it "doesn't fail for unknown engines" do
        expect do
          MassiveSitemap.ping(url, :unknown)
        end.to_not raise_error
      end

      it "doesn't fail when it can't talk to an engine" do
        MassiveSitemap.should_receive(:open).twice.and_raise(SocketError)

        MassiveSitemap.ping(url, [:google, :ask])
      end
    end
  end
end
