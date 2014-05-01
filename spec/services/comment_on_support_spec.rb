require 'spec_helper'

describe CommentOnSupport do
  let(:user) { User.new }
  subject { described_class.new(user, Support.new, {}) }

  describe "#commence!" do
    before { allow(subject).to receive(:deliver_email) }

    it "saves new comment" do
      expect(subject.new_comment).to receive(:save!)
      subject.commence!
    end

    it "sends email to subscribers" do
      allow(subject.new_comment).to receive(:save!)
      expect(subject).to receive(:deliver_email)
      subject.commence!
    end
  end

  describe "#subscribers" do
    before {
      subject.support.stub_chain(:comments, :pluck)
                      .and_return([11, 12, 13, user.id])
    }
    after { subject.subscribers }

    it "returns all related users without commenting one"  do
      expect(User).to receive(:where).with(id: [11, 12, 13])
    end

    context "commenting user is receiver of support" do
      it "returns all related users without receiver of support" do
        subject.stub(receiver_id: user.id) 
        expect(User).to receive(:where).with(id: [11, 12, 13])
      end
    end
  end
end
