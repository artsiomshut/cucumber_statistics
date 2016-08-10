require 'spec_helper'

module CucumberStatistics
  describe ScenarioStatistics do

    subject(:scenario_statistics) { ScenarioStatistics.new }
    subject(:overall_statistics) { OverallStatistics.new } #not sure if really need

    describe 'record' do
      it 'should create a record' do
        record "my scenario", 50, 'features/admin_cancel_account.feature:8'

        scenario_statistics.all.count.should == 1
        scenario_statistics.all['features/admin_cancel_account.feature:8'][:duration].should == 50
      end

      it 'should support multiple scenarios with the same name' do
        record "my scenario", 50, 'admin_cancel_account.feature:8'
        record "my scenario", 75, 'noise/features/super_admin/admin_cancel_account.feature:8'

        scenario_statistics.all.count.should == 2
        scenario_statistics.all['admin_cancel_account.feature:8'][:duration].should == 50
        scenario_statistics.all['features/super_admin/admin_cancel_account.feature:8'][:duration].should == 75
      end

      it 'chops off file path up to features/' do
        record "my scenario", 50, '/User/some/file/path/that/doesnt/matter really/features/admin_cancel_account.feature:8'
        scenario_statistics.all.keys.first.should == 'features/admin_cancel_account.feature:8'
      end

      it 'uses the whole string if the filepath doesnt include the features folder' do
        record "my scenario", 50, 'admin_cancel_account.feature:8'
        scenario_statistics.all.keys.first.should == 'admin_cancel_account.feature:8'
      end
    end

    describe 'all' do
      before(:each) do
        record "my scenario 1", 24, 'admin_cancel_account.feature:8'
        record "my scenario 1", 50, 'admin_cancel_account.feature:18'
        record "my scenario 2", 75, 'admin_cancel_account.feature:38'
      end

      it 'should return all records' do
        scenario_statistics.all.count.should == 3
        scenario_statistics.all.each_with_index do |file_colon_line, data, index|
          case index
          when 1
            file_colon_line.should == "admin_cancel_account.feature:8"
          when 2
            file_colon_line.should == "admin_cancel_account.feature:18"
          when 3
            file_colon_line.should == "admin_cancel_account.feature:38"
          end
        end
      end
    end

    describe 'set operations' do
      before(:each) do
        record "my scenario 1", 25, "admin_cancel_account.feature:8"
        record "my scenario 2", 50, "admin_cancel_account.feature:13"
        record "my scenario 3", 49, "admin_cancel_account.feature:15"
        record "my scenario 1", 51, "view_account.feature:3"
        record "my scenario 2", 75, "view_account.feature:6"
        record "my scenario 3", 10, "view_account.feature:22"
      end

      describe 'sort_by_property' do
        context 'should sort all records by any property' do
          it { scenario_statistics.sort_by_property(:scenario_name).first[0].should == "admin_cancel_account.feature:8" }
          it { scenario_statistics.sort_by_property(:scenario_name).last[0].should == "view_account.feature:22" }

          it { scenario_statistics.sort_by_property(:duration).first[0].should == "view_account.feature:22" }
          it { scenario_statistics.sort_by_property(:duration).last[0].should == "view_account.feature:6" }
        end
      end
    end

    def record(scenario_name, duration, file_colon_line)
      # fake a source for convenience
      scenario_statistics.record scenario_name, duration, file_colon_line
      #overall_statistics.step_count_inc
    end
  end
end