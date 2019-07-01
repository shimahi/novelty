class SentMail < ApplicationRecord
  belongs_to :order
  mount_uploader :attachment1, AttachmentUploader
  mount_uploader :attachment2, AttachmentUploader
  mount_uploader :attachment3, AttachmentUploader
end
