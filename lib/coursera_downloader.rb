$: << File.dirname(__FILE__)

module CourseraDownloader
  autoload :FileStore, "coursera_downloader/file_store"
  autoload :DocumentProcessor, "coursera_downloader/document_processor"
  autoload :Downloader, "coursera_downloader/downloader"
  autoload :Course, "coursera_downloader/course"
end
