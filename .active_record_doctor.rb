ActiveRecordDoctor.configure do |config|
  config.global :ignore_models, [
    "SolidQueue::BlockedExecution",
    "SolidQueue::ClaimedExecution",
    "SolidQueue::FailedExecution",
    "SolidQueue::Job",
    "SolidQueue::Pause",
    "SolidQueue::Process",
    "SolidQueue::ReadyExecution",
    "SolidQueue::RecurringExecution",
    "SolidQueue::RecurringTask",
    "SolidQueue::ScheduledExecution",
    "SolidQueue::Semaphore",
    "SolidCache::Entry",
    "SolidCable::Message"
  ]
end
