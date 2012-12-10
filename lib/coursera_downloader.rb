$: << File.dirname(__FILE__)

module CourseraDownloader
  autoload :Document, "coursera_downloader/document"
  autoload :FileStore, "coursera_downloader/file_store"
  autoload :DocumentProcessor, "coursera_downloader/document_processor"
  autoload :Downloader, "coursera_downloader/downloader"
  autoload :Policy, "coursera_downloader/policy"
  autoload :Course, "coursera_downloader/course"
end
