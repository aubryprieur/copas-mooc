module ApplicationHelper
  include Pagy::Frontend

  # Icônes SVG en ligne (tracés inspirés de Lucide, licence ISC), sans requête externe.
  ICONS = {
    "check" => '<path d="M20 6 9 17l-5-5"/>',
    "lock" => '<rect x="4" y="11" width="16" height="10" rx="2"/><path d="M8 11V7a4 4 0 0 1 8 0v4"/>',
    "play" => '<circle cx="12" cy="12" r="9"/><path d="m10 8 6 4-6 4z"/>',
    "clock" => '<circle cx="12" cy="12" r="9"/><path d="M12 7v5l3 2"/>',
    "users" => '<path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M22 21v-2a4 4 0 0 0-3-3.9M16 3.1a4 4 0 0 1 0 7.8"/>',
    "message" => '<path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/>',
    "alert" => '<path d="M12 9v4M12 17h.01"/><path d="M10.3 3.9 1.8 18a2 2 0 0 0 1.7 3h17a2 2 0 0 0 1.7-3L13.7 3.9a2 2 0 0 0-3.4 0z"/>',
    "file" => '<path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><path d="M14 2v6h6M9 15h6M9 11h2"/>',
    "download" => '<path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4M7 10l5 5 5-5M12 15V3"/>',
    "arrow-left" => '<path d="M19 12H5M12 19l-7-7 7-7"/>',
    "arrow-right" => '<path d="M5 12h14M12 5l7 7-7 7"/>',
    "chevron-up" => '<path d="m18 15-6-6-6 6"/>',
    "chevron-down" => '<path d="m6 9 6 6 6-6"/>',
    "plus" => '<path d="M12 5v14M5 12h14"/>',
    "pencil" => '<path d="M17 3a2.8 2.8 0 1 1 4 4L7.5 20.5 2 22l1.5-5.5z"/>',
    "trash" => '<path d="M3 6h18M8 6V4h8v2M19 6l-1 14H6L5 6"/>',
    "home" => '<path d="m3 10 9-7 9 7v10a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><path d="M9 22V12h6v10"/>',
    "book" => '<path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20V3H6.5A2.5 2.5 0 0 0 4 5.5z"/><path d="M4 19.5A2.5 2.5 0 0 0 6.5 22H20v-5"/>',
    "inbox" => '<path d="M22 12h-6l-2 3h-4l-2-3H2"/><path d="M5.5 5.1 2 12v6a2 2 0 0 0 2 2h16a2 2 0 0 0 2-2v-6l-3.5-6.9A2 2 0 0 0 16.8 4H7.2a2 2 0 0 0-1.7 1.1z"/>',
    "shield" => '<path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/>',
    "chart" => '<path d="M3 3v18h18"/><path d="M7 15l4-4 3 3 5-6"/>',
    "star" => '<path d="m12 2 3.1 6.3 6.9 1-5 4.9 1.2 6.8L12 17.8 5.8 21l1.2-6.8-5-4.9 6.9-1z"/>',
    "settings" => '<circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.7 1.7 0 0 0 .3 1.8l.1.1a2 2 0 1 1-2.8 2.8l-.1-.1a1.7 1.7 0 0 0-1.8-.3 1.7 1.7 0 0 0-1 1.5V21a2 2 0 1 1-4 0v-.1a1.7 1.7 0 0 0-1.1-1.5 1.7 1.7 0 0 0-1.8.3l-.1.1a2 2 0 1 1-2.8-2.8l.1-.1a1.7 1.7 0 0 0 .3-1.8 1.7 1.7 0 0 0-1.5-1H3a2 2 0 1 1 0-4h.1a1.7 1.7 0 0 0 1.5-1.1 1.7 1.7 0 0 0-.3-1.8l-.1-.1a2 2 0 1 1 2.8-2.8l.1.1a1.7 1.7 0 0 0 1.8.3H9a1.7 1.7 0 0 0 1-1.5V3a2 2 0 1 1 4 0v.1a1.7 1.7 0 0 0 1 1.5 1.7 1.7 0 0 0 1.8-.3l.1-.1a2 2 0 1 1 2.8 2.8l-.1.1a1.7 1.7 0 0 0-.3 1.8V9a1.7 1.7 0 0 0 1.5 1H21a2 2 0 1 1 0 4h-.1a1.7 1.7 0 0 0-1.5 1z"/>',
    "menu" => '<path d="M4 6h16M4 12h16M4 18h16"/>',
    "x" => '<path d="M18 6 6 18M6 6l12 12"/>',
    "eye" => '<path d="M2 12s3.5-7 10-7 10 7 10 7-3.5 7-10 7S2 12 2 12z"/><circle cx="12" cy="12" r="3"/>'
  }.freeze

  def icon(name, size: 18, css: "", label: nil)
    attrs = label ? %(role="img" aria-label="#{ERB::Util.h(label)}") : %(aria-hidden="true")
    %(<svg xmlns="http://www.w3.org/2000/svg" width="#{size}" height="#{size}" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" class="shrink-0 #{css}" #{attrs}>#{ICONS.fetch(name.to_s)}</svg>).html_safe
  end

  def page_title(text = nil)
    content_for(:title, text) if text
    [ content_for(:title), "COPAS Academy" ].compact_blank.join(" – ")
  end

  def nav_link(label, path, icon_name: nil, exact: false)
    active = exact ? current_page?(path) : request.path.start_with?(path)
    classes = active ? "nav-link nav-link-active" : "nav-link"
    link_to path, class: classes, aria: { current: (active ? "page" : nil) } do
      safe_join([ icon_name && icon(icon_name), tag.span(label) ].compact)
    end
  end

  def minutes_label(minutes)
    minutes = minutes.to_i
    return "#{minutes} min" if minutes < 60

    h, m = minutes.divmod(60)
    m.zero? ? "#{h} h" : "#{h} h #{m.to_s.rjust(2, '0')}"
  end

  def seconds_label(seconds) = seconds.to_i < 60 ? "< 1 min" : minutes_label(seconds.to_i / 60)

  def hours_label(value)
    return "—" if value.blank?

    "#{value.to_s.sub(/\.0\z/, '').tr('.', ',')} h"
  end

  def price_label(course)
    return "Sur devis" if course.price_cents.nil?
    return "Gratuit" if course.price_cents.zero?

    number_to_currency(course.price, unit: "€", format: "%n %u", separator: ",", delimiter: " ", precision: (course.price_cents % 100).zero? ? 0 : 2) + " HT"
  end

  def status_badge(text, tone = :neutral)
    tag.span(text, class: "badge badge-#{tone}")
  end

  def enrollment_tone(enrollment)
    { "requested" => :warning, "onboarding" => :info, "active" => :info, "completed" => :success,
      "abandoned" => :danger, "declined" => :neutral }.fetch(enrollment.status, :neutral)
  end

  def progress_bar(percent, label: "Progression")
    tag.div(class: "progress", role: "progressbar", aria: { label: label, valuenow: percent, valuemin: 0, valuemax: 100 }) do
      tag.div(class: "progress-fill", style: "width: #{percent.to_i.clamp(0, 100)}%")
    end
  end

  def avatar_for(user, size: 36)
    if user.avatar.attached?
      image_tag user.avatar.variant(:thumb), alt: "", class: "avatar", width: size, height: size
    else
      tag.span(user.initials, class: "avatar avatar-initials", style: "width:#{size}px;height:#{size}px", aria: { hidden: true })
    end
  end

  def simple_format_text(text) = simple_format(h(text.to_s), {}, sanitize: false)

  def can_edit? = current_user&.staff?

  def org = Rails.application.config_for(:organization)

  def rich_or_text(value) = value.respond_to?(:body) ? value : simple_format_text(value)
end
