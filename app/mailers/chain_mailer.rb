class ChainMailer < ActionMailer::Base
  include SendGrid
  sendgrid_category :use_subject_lines
  default from: Figaro.env.mailer_sender
  
  def chain_created user, chain
    @user = user
    @chain = chain
    mail to: @user.email, subject: "Big Earth Blockchain '#{@chain.title}' created!"
  end
  
  def chain_destroyed user, title
    @user = user
    @title = title
    mail to: @user.email, subject: "Big Earth Blockchain '#{@title}' destroyed!"
  end
end
